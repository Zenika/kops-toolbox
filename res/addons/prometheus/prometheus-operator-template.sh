#!/bin/bash

cat << COINCOIN

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus-operator-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-operator
subjects:
- kind: ServiceAccount
  name: prometheus-operator
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus-operator
rules:
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - "*"
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - "*"
- apiGroups:
  - monitoring.coreos.com
  resources:
  - alertmanagers
  - prometheuses
  - prometheuses/finalizers
  - alertmanagers/finalizers
  - servicemonitors
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs: ["*"]
- apiGroups: [""]
  resources:
  - configmaps
  - secrets
  verbs: ["*"]
- apiGroups: [""]
  resources:
  - pods
  verbs: ["list", "delete"]
- apiGroups: [""]
  resources:
  - services
  - endpoints
  verbs: ["get", "create", "update"]
- apiGroups: [""]
  resources:
  - nodes
  - namespaces
  verbs: ["list", "watch"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-operator
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    k8s-app: prometheus-operator
  name: prometheus-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: prometheus-operator
  template:
    metadata:
      labels:
        k8s-app: prometheus-operator
    spec:
      containers:
      - args:
        - --kubelet-service=kube-system/kubelet
        - --config-reloader-image=quay.io/coreos/configmap-reload:v0.0.1
        image: quay.io/coreos/prometheus-operator:v0.19.0
        name: prometheus-operator
        ports:
        - containerPort: 8080
          name: http
        resources:
          limits:
            cpu: 200m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 50Mi
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: prometheus-operator

---

apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  creationTimestamp: null
  name: alertmanagers.monitoring.coreos.com
spec:
  group: monitoring.coreos.com
  names:
    kind: Alertmanager
    plural: alertmanagers
  scope: Namespaced
  validation:
    openAPIV3Schema:
      description: Describes an Alertmanager cluster.
      properties:
        apiVersion:
          description: 'APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
          type: string
        kind:
          description: 'Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the client
            submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
          type: string
        spec:
          description: 'Specification of the desired behavior of the Alertmanager
            cluster. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status'
          properties:
            affinity:
              description: Affinity is a group of affinity scheduling rules.
              properties:
                nodeAffinity:
                  description: Node affinity is a group of node affinity scheduling
                    rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the affinity expressions specified by this field,
                        but it may choose a node that violates one or more of the
                        expressions. The node that is most preferred is the one with
                        the greatest sum of weights, i.e. for each node that meets
                        all of the scheduling requirements (resource request, requiredDuringScheduling
                        affinity expressions, etc.), compute a sum by iterating through
                        the elements of this field and adding "weight" to the sum
                        if the node matches the corresponding matchExpressions; the
                        node(s) with the highest sum are the most preferred.
                      items:
                        description: An empty preferred scheduling term matches all
                          objects with implicit weight 0 (i.e. it's a no-op). A null
                          preferred scheduling term matches no objects (i.e. is also
                          a no-op).
                        properties:
                          preference:
                            description: A null or empty node selector term matches
                              no objects.
                            properties:
                              matchExpressions:
                                description: Required. A list of node selector requirements.
                                  The requirements are ANDed.
                                items:
                                  description: A node selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: The label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: Represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists, DoesNotExist. Gt, and Lt.
                                      type: string
                                    values:
                                      description: An array of string values. If the
                                        operator is In or NotIn, the values array
                                        must be non-empty. If the operator is Exists
                                        or DoesNotExist, the values array must be
                                        empty. If the operator is Gt or Lt, the values
                                        array must have a single element, which will
                                        be interpreted as an integer. This array is
                                        replaced during a strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                            required:
                            - matchExpressions
                          weight:
                            description: Weight associated with matching the corresponding
                              nodeSelectorTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - preference
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: A node selector represents the union of the results
                        of one or more label queries over a set of nodes; that is,
                        it represents the OR of the selectors represented by the node
                        selector terms.
                      properties:
                        nodeSelectorTerms:
                          description: Required. A list of node selector terms. The
                            terms are ORed.
                          items:
                            description: A null or empty node selector term matches
                              no objects.
                            properties:
                              matchExpressions:
                                description: Required. A list of node selector requirements.
                                  The requirements are ANDed.
                                items:
                                  description: A node selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: The label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: Represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists, DoesNotExist. Gt, and Lt.
                                      type: string
                                    values:
                                      description: An array of string values. If the
                                        operator is In or NotIn, the values array
                                        must be non-empty. If the operator is Exists
                                        or DoesNotExist, the values array must be
                                        empty. If the operator is Gt or Lt, the values
                                        array must have a single element, which will
                                        be interpreted as an integer. This array is
                                        replaced during a strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                            required:
                            - matchExpressions
                          type: array
                      required:
                      - nodeSelectorTerms
                podAffinity:
                  description: Pod affinity is a group of inter pod affinity scheduling
                    rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the affinity expressions specified by this field,
                        but it may choose a node that violates one or more of the
                        expressions. The node that is most preferred is the one with
                        the greatest sum of weights, i.e. for each node that meets
                        all of the scheduling requirements (resource request, requiredDuringScheduling
                        affinity expressions, etc.), compute a sum by iterating through
                        the elements of this field and adding "weight" to the sum
                        if the node has pods which matches the corresponding podAffinityTerm;
                        the node(s) with the highest sum are the most preferred.
                      items:
                        description: The weights of all of the matched WeightedPodAffinityTerm
                          fields are added per-node to find the most preferred node(s)
                        properties:
                          podAffinityTerm:
                            description: Defines a set of pods (namely those matching
                              the labelSelector relative to the given namespace(s))
                              that this pod should be co-located (affinity) or not
                              co-located (anti-affinity) with, where co-located is
                              defined as running on a node whose value of the label
                              with key <topologyKey> matches that of any node on which
                              a pod of the set of pods is running
                            properties:
                              labelSelector:
                                description: A label selector is a label query over
                                  a set of resources. The result of matchLabels and
                                  matchExpressions are ANDed. An empty label selector
                                  matches all objects. A null label selector matches
                                  no objects.
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label
                                      selector requirements. The requirements are
                                      ANDed.
                                    items:
                                      description: A label selector requirement is
                                        a selector that contains values, a key, and
                                        an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the
                                            selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's
                                            relationship to a set of values. Valid
                                            operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string
                                            values. If the operator is In or NotIn,
                                            the values array must be non-empty. If
                                            the operator is Exists or DoesNotExist,
                                            the values array must be empty. This array
                                            is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                      - key
                                      - operator
                                    type: array
                                  matchLabels:
                                    description: matchLabels is a map of {key,value}
                                      pairs. A single {key,value} in the matchLabels
                                      map is equivalent to an element of matchExpressions,
                                      whose key field is "key", the operator is "In",
                                      and the values array contains only "value".
                                      The requirements are ANDed.
                                    type: object
                              namespaces:
                                description: namespaces specifies which namespaces
                                  the labelSelector applies to (matches against);
                                  null or empty list means "this pod's namespace"
                                items:
                                  type: string
                                type: array
                              topologyKey:
                                description: This pod should be co-located (affinity)
                                  or not co-located (anti-affinity) with the pods
                                  matching the labelSelector in the specified namespaces,
                                  where co-located is defined as running on a node
                                  whose value of the label with key topologyKey matches
                                  that of any node on which any of the selected pods
                                  is running. Empty topologyKey is not allowed.
                                type: string
                            required:
                            - topologyKey
                          weight:
                            description: weight associated with matching the corresponding
                              podAffinityTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - podAffinityTerm
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: If the affinity requirements specified by this
                        field are not met at scheduling time, the pod will not be
                        scheduled onto the node. If the affinity requirements specified
                        by this field cease to be met at some point during pod execution
                        (e.g. due to a pod label update), the system may or may not
                        try to eventually evict the pod from its node. When there
                        are multiple elements, the lists of nodes corresponding to
                        each podAffinityTerm are intersected, i.e. all terms must
                        be satisfied.
                      items:
                        description: Defines a set of pods (namely those matching
                          the labelSelector relative to the given namespace(s)) that
                          this pod should be co-located (affinity) or not co-located
                          (anti-affinity) with, where co-located is defined as running
                          on a node whose value of the label with key <topologyKey>
                          matches that of any node on which a pod of the set of pods
                          is running
                        properties:
                          labelSelector:
                            description: A label selector is a label query over a
                              set of resources. The result of matchLabels and matchExpressions
                              are ANDed. An empty label selector matches all objects.
                              A null label selector matches no objects.
                            properties:
                              matchExpressions:
                                description: matchExpressions is a list of label selector
                                  requirements. The requirements are ANDed.
                                items:
                                  description: A label selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: key is the label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: operator represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists and DoesNotExist.
                                      type: string
                                    values:
                                      description: values is an array of string values.
                                        If the operator is In or NotIn, the values
                                        array must be non-empty. If the operator is
                                        Exists or DoesNotExist, the values array must
                                        be empty. This array is replaced during a
                                        strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                              matchLabels:
                                description: matchLabels is a map of {key,value} pairs.
                                  A single {key,value} in the matchLabels map is equivalent
                                  to an element of matchExpressions, whose key field
                                  is "key", the operator is "In", and the values array
                                  contains only "value". The requirements are ANDed.
                                type: object
                          namespaces:
                            description: namespaces specifies which namespaces the
                              labelSelector applies to (matches against); null or
                              empty list means "this pod's namespace"
                            items:
                              type: string
                            type: array
                          topologyKey:
                            description: This pod should be co-located (affinity)
                              or not co-located (anti-affinity) with the pods matching
                              the labelSelector in the specified namespaces, where
                              co-located is defined as running on a node whose value
                              of the label with key topologyKey matches that of any
                              node on which any of the selected pods is running. Empty
                              topologyKey is not allowed.
                            type: string
                        required:
                        - topologyKey
                      type: array
                podAntiAffinity:
                  description: Pod anti affinity is a group of inter pod anti affinity
                    scheduling rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the anti-affinity expressions specified by this
                        field, but it may choose a node that violates one or more
                        of the expressions. The node that is most preferred is the
                        one with the greatest sum of weights, i.e. for each node that
                        meets all of the scheduling requirements (resource request,
                        requiredDuringScheduling anti-affinity expressions, etc.),
                        compute a sum by iterating through the elements of this field
                        and adding "weight" to the sum if the node has pods which
                        matches the corresponding podAffinityTerm; the node(s) with
                        the highest sum are the most preferred.
                      items:
                        description: The weights of all of the matched WeightedPodAffinityTerm
                          fields are added per-node to find the most preferred node(s)
                        properties:
                          podAffinityTerm:
                            description: Defines a set of pods (namely those matching
                              the labelSelector relative to the given namespace(s))
                              that this pod should be co-located (affinity) or not
                              co-located (anti-affinity) with, where co-located is
                              defined as running on a node whose value of the label
                              with key <topologyKey> matches that of any node on which
                              a pod of the set of pods is running
                            properties:
                              labelSelector:
                                description: A label selector is a label query over
                                  a set of resources. The result of matchLabels and
                                  matchExpressions are ANDed. An empty label selector
                                  matches all objects. A null label selector matches
                                  no objects.
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label
                                      selector requirements. The requirements are
                                      ANDed.
                                    items:
                                      description: A label selector requirement is
                                        a selector that contains values, a key, and
                                        an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the
                                            selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's
                                            relationship to a set of values. Valid
                                            operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string
                                            values. If the operator is In or NotIn,
                                            the values array must be non-empty. If
                                            the operator is Exists or DoesNotExist,
                                            the values array must be empty. This array
                                            is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                      - key
                                      - operator
                                    type: array
                                  matchLabels:
                                    description: matchLabels is a map of {key,value}
                                      pairs. A single {key,value} in the matchLabels
                                      map is equivalent to an element of matchExpressions,
                                      whose key field is "key", the operator is "In",
                                      and the values array contains only "value".
                                      The requirements are ANDed.
                                    type: object
                              namespaces:
                                description: namespaces specifies which namespaces
                                  the labelSelector applies to (matches against);
                                  null or empty list means "this pod's namespace"
                                items:
                                  type: string
                                type: array
                              topologyKey:
                                description: This pod should be co-located (affinity)
                                  or not co-located (anti-affinity) with the pods
                                  matching the labelSelector in the specified namespaces,
                                  where co-located is defined as running on a node
                                  whose value of the label with key topologyKey matches
                                  that of any node on which any of the selected pods
                                  is running. Empty topologyKey is not allowed.
                                type: string
                            required:
                            - topologyKey
                          weight:
                            description: weight associated with matching the corresponding
                              podAffinityTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - podAffinityTerm
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: If the anti-affinity requirements specified by
                        this field are not met at scheduling time, the pod will not
                        be scheduled onto the node. If the anti-affinity requirements
                        specified by this field cease to be met at some point during
                        pod execution (e.g. due to a pod label update), the system
                        may or may not try to eventually evict the pod from its node.
                        When there are multiple elements, the lists of nodes corresponding
                        to each podAffinityTerm are intersected, i.e. all terms must
                        be satisfied.
                      items:
                        description: Defines a set of pods (namely those matching
                          the labelSelector relative to the given namespace(s)) that
                          this pod should be co-located (affinity) or not co-located
                          (anti-affinity) with, where co-located is defined as running
                          on a node whose value of the label with key <topologyKey>
                          matches that of any node on which a pod of the set of pods
                          is running
                        properties:
                          labelSelector:
                            description: A label selector is a label query over a
                              set of resources. The result of matchLabels and matchExpressions
                              are ANDed. An empty label selector matches all objects.
                              A null label selector matches no objects.
                            properties:
                              matchExpressions:
                                description: matchExpressions is a list of label selector
                                  requirements. The requirements are ANDed.
                                items:
                                  description: A label selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: key is the label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: operator represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists and DoesNotExist.
                                      type: string
                                    values:
                                      description: values is an array of string values.
                                        If the operator is In or NotIn, the values
                                        array must be non-empty. If the operator is
                                        Exists or DoesNotExist, the values array must
                                        be empty. This array is replaced during a
                                        strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                              matchLabels:
                                description: matchLabels is a map of {key,value} pairs.
                                  A single {key,value} in the matchLabels map is equivalent
                                  to an element of matchExpressions, whose key field
                                  is "key", the operator is "In", and the values array
                                  contains only "value". The requirements are ANDed.
                                type: object
                          namespaces:
                            description: namespaces specifies which namespaces the
                              labelSelector applies to (matches against); null or
                              empty list means "this pod's namespace"
                            items:
                              type: string
                            type: array
                          topologyKey:
                            description: This pod should be co-located (affinity)
                              or not co-located (anti-affinity) with the pods matching
                              the labelSelector in the specified namespaces, where
                              co-located is defined as running on a node whose value
                              of the label with key topologyKey matches that of any
                              node on which any of the selected pods is running. Empty
                              topologyKey is not allowed.
                            type: string
                        required:
                        - topologyKey
                      type: array
            baseImage:
              description: Base image that is used to deploy pods, without tag.
              type: string
            containers:
              description: Containers allows injecting additional containers. This
                is meant to allow adding an authentication proxy to an Alertmanager
                pod.
              items:
                description: A single application container that you want to run within
                  a pod.
                properties:
                  args:
                    description: 'Arguments to the entrypoint. The docker image''s
                      CMD is used if this is not provided. Variable references \$(VAR_NAME)
                      are expanded using the container''s environment. If a variable
                      cannot be resolved, the reference in the input string will be
                      unchanged. The \$(VAR_NAME) syntax can be escaped with a double
                      $$, ie: $\$(VAR_NAME). Escaped references will never be expanded,
                      regardless of whether the variable exists or not. Cannot be
                      updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell'
                    items:
                      type: string
                    type: array
                  command:
                    description: 'Entrypoint array. Not executed within a shell. The
                      docker image''s ENTRYPOINT is used if this is not provided.
                      Variable references \$(VAR_NAME) are expanded using the container''s
                      environment. If a variable cannot be resolved, the reference
                      in the input string will be unchanged. The \$(VAR_NAME) syntax
                      can be escaped with a double $$, ie: $\$(VAR_NAME). Escaped references
                      will never be expanded, regardless of whether the variable exists
                      or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell'
                    items:
                      type: string
                    type: array
                  env:
                    description: List of environment variables to set in the container.
                      Cannot be updated.
                    items:
                      description: EnvVar represents an environment variable present
                        in a Container.
                      properties:
                        name:
                          description: Name of the environment variable. Must be a
                            C_IDENTIFIER.
                          type: string
                        value:
                          description: 'Variable references \$(VAR_NAME) are expanded
                            using the previous defined environment variables in the
                            container and any service environment variables. If a
                            variable cannot be resolved, the reference in the input
                            string will be unchanged. The \$(VAR_NAME) syntax can be
                            escaped with a double $$, ie: $\$(VAR_NAME). Escaped references
                            will never be expanded, regardless of whether the variable
                            exists or not. Defaults to "".'
                          type: string
                        valueFrom:
                          description: EnvVarSource represents a source for the value
                            of an EnvVar.
                          properties:
                            configMapKeyRef:
                              description: Selects a key from a ConfigMap.
                              properties:
                                key:
                                  description: The key to select.
                                  type: string
                                name:
                                  description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                                  type: string
                                optional:
                                  description: Specify whether the ConfigMap or it's
                                    key must be defined
                                  type: boolean
                              required:
                              - key
                            fieldRef:
                              description: ObjectFieldSelector selects an APIVersioned
                                field of an object.
                              properties:
                                apiVersion:
                                  description: Version of the schema the FieldPath
                                    is written in terms of, defaults to "v1".
                                  type: string
                                fieldPath:
                                  description: Path of the field to select in the
                                    specified API version.
                                  type: string
                              required:
                              - fieldPath
                            resourceFieldRef:
                              description: ResourceFieldSelector represents container
                                resources (cpu, memory) and their output format
                              properties:
                                containerName:
                                  description: 'Container name: required for volumes,
                                    optional for env vars'
                                  type: string
                                divisor: {}
                                resource:
                                  description: 'Required: resource to select'
                                  type: string
                              required:
                              - resource
                            secretKeyRef:
                              description: SecretKeySelector selects a key of a Secret.
                              properties:
                                key:
                                  description: The key of the secret to select from.  Must
                                    be a valid secret key.
                                  type: string
                                name:
                                  description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                                  type: string
                                optional:
                                  description: Specify whether the Secret or it's
                                    key must be defined
                                  type: boolean
                              required:
                              - key
                      required:
                      - name
                    type: array
                  envFrom:
                    description: List of sources to populate environment variables
                      in the container. The keys defined within a source must be a
                      C_IDENTIFIER. All invalid keys will be reported as an event
                      when the container is starting. When a key exists in multiple
                      sources, the value associated with the last source will take
                      precedence. Values defined by an Env with a duplicate key will
                      take precedence. Cannot be updated.
                    items:
                      description: EnvFromSource represents the source of a set of
                        ConfigMaps
                      properties:
                        configMapRef:
                          description: |-
                            ConfigMapEnvSource selects a ConfigMap to populate the environment variables with.

                            The contents of the target ConfigMap's Data field will represent the key-value pairs as environment variables.
                          properties:
                            name:
                              description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                              type: string
                            optional:
                              description: Specify whether the ConfigMap must be defined
                              type: boolean
                        prefix:
                          description: An optional identifer to prepend to each key
                            in the ConfigMap. Must be a C_IDENTIFIER.
                          type: string
                        secretRef:
                          description: |-
                            SecretEnvSource selects a Secret to populate the environment variables with.

                            The contents of the target Secret's Data field will represent the key-value pairs as environment variables.
                          properties:
                            name:
                              description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                              type: string
                            optional:
                              description: Specify whether the Secret must be defined
                              type: boolean
                    type: array
                  image:
                    description: 'Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                      This field is optional to allow higher level config management
                      to default or override container images in workload controllers
                      like Deployments and StatefulSets.'
                    type: string
                  imagePullPolicy:
                    description: 'Image pull policy. One of Always, Never, IfNotPresent.
                      Defaults to Always if :latest tag is specified, or IfNotPresent
                      otherwise. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images'
                    type: string
                  lifecycle:
                    description: Lifecycle describes actions that the management system
                      should take in response to container lifecycle events. For the
                      PostStart and PreStop lifecycle handlers, management of the
                      container blocks until the action is complete, unless the container
                      process fails, in which case the handler is aborted.
                    properties:
                      postStart:
                        description: Handler defines a specific action that should
                          be taken
                        properties:
                          exec:
                            description: ExecAction describes a "run in container"
                              action.
                            properties:
                              command:
                                description: Command is the command line to execute
                                  inside the container, the working directory for
                                  the command  is root ('/') in the container's filesystem.
                                  The command is simply exec'd, it is not run inside
                                  a shell, so traditional shell instructions ('|',
                                  etc) won't work. To use a shell, you need to explicitly
                                  call out to that shell. Exit status of 0 is treated
                                  as live/healthy and non-zero is unhealthy.
                                items:
                                  type: string
                                type: array
                          httpGet:
                            description: HTTPGetAction describes an action based on
                              HTTP Get requests.
                            properties:
                              host:
                                description: Host name to connect to, defaults to
                                  the pod IP. You probably want to set "Host" in httpHeaders
                                  instead.
                                type: string
                              httpHeaders:
                                description: Custom headers to set in the request.
                                  HTTP allows repeated headers.
                                items:
                                  description: HTTPHeader describes a custom header
                                    to be used in HTTP probes
                                  properties:
                                    name:
                                      description: The header field name
                                      type: string
                                    value:
                                      description: The header field value
                                      type: string
                                  required:
                                  - name
                                  - value
                                type: array
                              path:
                                description: Path to access on the HTTP server.
                                type: string
                              port: {}
                              scheme:
                                description: Scheme to use for connecting to the host.
                                  Defaults to HTTP.
                                type: string
                            required:
                            - port
                          tcpSocket:
                            description: TCPSocketAction describes an action based
                              on opening a socket
                            properties:
                              host:
                                description: 'Optional: Host name to connect to, defaults
                                  to the pod IP.'
                                type: string
                              port: {}
                            required:
                            - port
                      preStop:
                        description: Handler defines a specific action that should
                          be taken
                        properties:
                          exec:
                            description: ExecAction describes a "run in container"
                              action.
                            properties:
                              command:
                                description: Command is the command line to execute
                                  inside the container, the working directory for
                                  the command  is root ('/') in the container's filesystem.
                                  The command is simply exec'd, it is not run inside
                                  a shell, so traditional shell instructions ('|',
                                  etc) won't work. To use a shell, you need to explicitly
                                  call out to that shell. Exit status of 0 is treated
                                  as live/healthy and non-zero is unhealthy.
                                items:
                                  type: string
                                type: array
                          httpGet:
                            description: HTTPGetAction describes an action based on
                              HTTP Get requests.
                            properties:
                              host:
                                description: Host name to connect to, defaults to
                                  the pod IP. You probably want to set "Host" in httpHeaders
                                  instead.
                                type: string
                              httpHeaders:
                                description: Custom headers to set in the request.
                                  HTTP allows repeated headers.
                                items:
                                  description: HTTPHeader describes a custom header
                                    to be used in HTTP probes
                                  properties:
                                    name:
                                      description: The header field name
                                      type: string
                                    value:
                                      description: The header field value
                                      type: string
                                  required:
                                  - name
                                  - value
                                type: array
                              path:
                                description: Path to access on the HTTP server.
                                type: string
                              port: {}
                              scheme:
                                description: Scheme to use for connecting to the host.
                                  Defaults to HTTP.
                                type: string
                            required:
                            - port
                          tcpSocket:
                            description: TCPSocketAction describes an action based
                              on opening a socket
                            properties:
                              host:
                                description: 'Optional: Host name to connect to, defaults
                                  to the pod IP.'
                                type: string
                              port: {}
                            required:
                            - port
                  livenessProbe:
                    description: Probe describes a health check to be performed against
                      a container to determine whether it is alive or ready to receive
                      traffic.
                    properties:
                      exec:
                        description: ExecAction describes a "run in container" action.
                        properties:
                          command:
                            description: Command is the command line to execute inside
                              the container, the working directory for the command  is
                              root ('/') in the container's filesystem. The command
                              is simply exec'd, it is not run inside a shell, so traditional
                              shell instructions ('|', etc) won't work. To use a shell,
                              you need to explicitly call out to that shell. Exit
                              status of 0 is treated as live/healthy and non-zero
                              is unhealthy.
                            items:
                              type: string
                            type: array
                      failureThreshold:
                        description: Minimum consecutive failures for the probe to
                          be considered failed after having succeeded. Defaults to
                          3. Minimum value is 1.
                        format: int32
                        type: integer
                      httpGet:
                        description: HTTPGetAction describes an action based on HTTP
                          Get requests.
                        properties:
                          host:
                            description: Host name to connect to, defaults to the
                              pod IP. You probably want to set "Host" in httpHeaders
                              instead.
                            type: string
                          httpHeaders:
                            description: Custom headers to set in the request. HTTP
                              allows repeated headers.
                            items:
                              description: HTTPHeader describes a custom header to
                                be used in HTTP probes
                              properties:
                                name:
                                  description: The header field name
                                  type: string
                                value:
                                  description: The header field value
                                  type: string
                              required:
                              - name
                              - value
                            type: array
                          path:
                            description: Path to access on the HTTP server.
                            type: string
                          port: {}
                          scheme:
                            description: Scheme to use for connecting to the host.
                              Defaults to HTTP.
                            type: string
                        required:
                        - port
                      initialDelaySeconds:
                        description: 'Number of seconds after the container has started
                          before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                      periodSeconds:
                        description: How often (in seconds) to perform the probe.
                          Default to 10 seconds. Minimum value is 1.
                        format: int32
                        type: integer
                      successThreshold:
                        description: Minimum consecutive successes for the probe to
                          be considered successful after having failed. Defaults to
                          1. Must be 1 for liveness. Minimum value is 1.
                        format: int32
                        type: integer
                      tcpSocket:
                        description: TCPSocketAction describes an action based on
                          opening a socket
                        properties:
                          host:
                            description: 'Optional: Host name to connect to, defaults
                              to the pod IP.'
                            type: string
                          port: {}
                        required:
                        - port
                      timeoutSeconds:
                        description: 'Number of seconds after which the probe times
                          out. Defaults to 1 second. Minimum value is 1. More info:
                          https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                  name:
                    description: Name of the container specified as a DNS_LABEL. Each
                      container in a pod must have a unique name (DNS_LABEL). Cannot
                      be updated.
                    type: string
                  ports:
                    description: List of ports to expose from the container. Exposing
                      a port here gives the system additional information about the
                      network connections a container uses, but is primarily informational.
                      Not specifying a port here DOES NOT prevent that port from being
                      exposed. Any port which is listening on the default "0.0.0.0"
                      address inside a container will be accessible from the network.
                      Cannot be updated.
                    items:
                      description: ContainerPort represents a network port in a single
                        container.
                      properties:
                        containerPort:
                          description: Number of port to expose on the pod's IP address.
                            This must be a valid port number, 0 < x < 65536.
                          format: int32
                          type: integer
                        hostIP:
                          description: What host IP to bind the external port to.
                          type: string
                        hostPort:
                          description: Number of port to expose on the host. If specified,
                            this must be a valid port number, 0 < x < 65536. If HostNetwork
                            is specified, this must match ContainerPort. Most containers
                            do not need this.
                          format: int32
                          type: integer
                        name:
                          description: If specified, this must be an IANA_SVC_NAME
                            and unique within the pod. Each named port in a pod must
                            have a unique name. Name for the port that can be referred
                            to by services.
                          type: string
                        protocol:
                          description: Protocol for port. Must be UDP or TCP. Defaults
                            to "TCP".
                          type: string
                      required:
                      - containerPort
                    type: array
                  readinessProbe:
                    description: Probe describes a health check to be performed against
                      a container to determine whether it is alive or ready to receive
                      traffic.
                    properties:
                      exec:
                        description: ExecAction describes a "run in container" action.
                        properties:
                          command:
                            description: Command is the command line to execute inside
                              the container, the working directory for the command  is
                              root ('/') in the container's filesystem. The command
                              is simply exec'd, it is not run inside a shell, so traditional
                              shell instructions ('|', etc) won't work. To use a shell,
                              you need to explicitly call out to that shell. Exit
                              status of 0 is treated as live/healthy and non-zero
                              is unhealthy.
                            items:
                              type: string
                            type: array
                      failureThreshold:
                        description: Minimum consecutive failures for the probe to
                          be considered failed after having succeeded. Defaults to
                          3. Minimum value is 1.
                        format: int32
                        type: integer
                      httpGet:
                        description: HTTPGetAction describes an action based on HTTP
                          Get requests.
                        properties:
                          host:
                            description: Host name to connect to, defaults to the
                              pod IP. You probably want to set "Host" in httpHeaders
                              instead.
                            type: string
                          httpHeaders:
                            description: Custom headers to set in the request. HTTP
                              allows repeated headers.
                            items:
                              description: HTTPHeader describes a custom header to
                                be used in HTTP probes
                              properties:
                                name:
                                  description: The header field name
                                  type: string
                                value:
                                  description: The header field value
                                  type: string
                              required:
                              - name
                              - value
                            type: array
                          path:
                            description: Path to access on the HTTP server.
                            type: string
                          port: {}
                          scheme:
                            description: Scheme to use for connecting to the host.
                              Defaults to HTTP.
                            type: string
                        required:
                        - port
                      initialDelaySeconds:
                        description: 'Number of seconds after the container has started
                          before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                      periodSeconds:
                        description: How often (in seconds) to perform the probe.
                          Default to 10 seconds. Minimum value is 1.
                        format: int32
                        type: integer
                      successThreshold:
                        description: Minimum consecutive successes for the probe to
                          be considered successful after having failed. Defaults to
                          1. Must be 1 for liveness. Minimum value is 1.
                        format: int32
                        type: integer
                      tcpSocket:
                        description: TCPSocketAction describes an action based on
                          opening a socket
                        properties:
                          host:
                            description: 'Optional: Host name to connect to, defaults
                              to the pod IP.'
                            type: string
                          port: {}
                        required:
                        - port
                      timeoutSeconds:
                        description: 'Number of seconds after which the probe times
                          out. Defaults to 1 second. Minimum value is 1. More info:
                          https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                  resources:
                    description: ResourceRequirements describes the compute resource
                      requirements.
                    properties:
                      limits:
                        description: 'Limits describes the maximum amount of compute
                          resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                        type: object
                      requests:
                        description: 'Requests describes the minimum amount of compute
                          resources required. If Requests is omitted for a container,
                          it defaults to Limits if that is explicitly specified, otherwise
                          to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                        type: object
                  securityContext:
                    description: SecurityContext holds security configuration that
                      will be applied to a container. Some fields are present in both
                      SecurityContext and PodSecurityContext.  When both are set,
                      the values in SecurityContext take precedence.
                    properties:
                      allowPrivilegeEscalation:
                        description: 'AllowPrivilegeEscalation controls whether a
                          process can gain more privileges than its parent process.
                          This bool directly controls if the no_new_privs flag will
                          be set on the container process. AllowPrivilegeEscalation
                          is true always when the container is: 1) run as Privileged
                          2) has CAP_SYS_ADMIN'
                        type: boolean
                      capabilities:
                        description: Adds and removes POSIX capabilities from running
                          containers.
                        properties:
                          add:
                            description: Added capabilities
                            items:
                              type: string
                            type: array
                          drop:
                            description: Removed capabilities
                            items:
                              type: string
                            type: array
                      privileged:
                        description: Run container in privileged mode. Processes in
                          privileged containers are essentially equivalent to root
                          on the host. Defaults to false.
                        type: boolean
                      readOnlyRootFilesystem:
                        description: Whether this container has a read-only root filesystem.
                          Default is false.
                        type: boolean
                      runAsNonRoot:
                        description: Indicates that the container must run as a non-root
                          user. If true, the Kubelet will validate the image at runtime
                          to ensure that it does not run as UID 0 (root) and fail
                          to start the container if it does. If unset or false, no
                          such validation will be performed. May also be set in PodSecurityContext.  If
                          set in both SecurityContext and PodSecurityContext, the
                          value specified in SecurityContext takes precedence.
                        type: boolean
                      runAsUser:
                        description: The UID to run the entrypoint of the container
                          process. Defaults to user specified in image metadata if
                          unspecified. May also be set in PodSecurityContext.  If
                          set in both SecurityContext and PodSecurityContext, the
                          value specified in SecurityContext takes precedence.
                        format: int64
                        type: integer
                      seLinuxOptions:
                        description: SELinuxOptions are the labels to be applied to
                          the container
                        properties:
                          level:
                            description: Level is SELinux level label that applies
                              to the container.
                            type: string
                          role:
                            description: Role is a SELinux role label that applies
                              to the container.
                            type: string
                          type:
                            description: Type is a SELinux type label that applies
                              to the container.
                            type: string
                          user:
                            description: User is a SELinux user label that applies
                              to the container.
                            type: string
                  stdin:
                    description: Whether this container should allocate a buffer for
                      stdin in the container runtime. If this is not set, reads from
                      stdin in the container will always result in EOF. Default is
                      false.
                    type: boolean
                  stdinOnce:
                    description: Whether the container runtime should close the stdin
                      channel after it has been opened by a single attach. When stdin
                      is true the stdin stream will remain open across multiple attach
                      sessions. If stdinOnce is set to true, stdin is opened on container
                      start, is empty until the first client attaches to stdin, and
                      then remains open and accepts data until the client disconnects,
                      at which time stdin is closed and remains closed until the container
                      is restarted. If this flag is false, a container processes that
                      reads from stdin will never receive an EOF. Default is false
                    type: boolean
                  terminationMessagePath:
                    description: 'Optional: Path at which the file to which the container''s
                      termination message will be written is mounted into the container''s
                      filesystem. Message written is intended to be brief final status,
                      such as an assertion failure message. Will be truncated by the
                      node if greater than 4096 bytes. The total message length across
                      all containers will be limited to 12kb. Defaults to /dev/termination-log.
                      Cannot be updated.'
                    type: string
                  terminationMessagePolicy:
                    description: Indicate how the termination message should be populated.
                      File will use the contents of terminationMessagePath to populate
                      the container status message on both success and failure. FallbackToLogsOnError
                      will use the last chunk of container log output if the termination
                      message file is empty and the container exited with an error.
                      The log output is limited to 2048 bytes or 80 lines, whichever
                      is smaller. Defaults to File. Cannot be updated.
                    type: string
                  tty:
                    description: Whether this container should allocate a TTY for
                      itself, also requires 'stdin' to be true. Default is false.
                    type: boolean
                  volumeDevices:
                    description: volumeDevices is the list of block devices to be
                      used by the container. This is an alpha feature and may change
                      in the future.
                    items:
                      description: volumeDevice describes a mapping of a raw block
                        device within a container.
                      properties:
                        devicePath:
                          description: devicePath is the path inside of the container
                            that the device will be mapped to.
                          type: string
                        name:
                          description: name must match the name of a persistentVolumeClaim
                            in the pod
                          type: string
                      required:
                      - name
                      - devicePath
                    type: array
                  volumeMounts:
                    description: Pod volumes to mount into the container's filesystem.
                      Cannot be updated.
                    items:
                      description: VolumeMount describes a mounting of a Volume within
                        a container.
                      properties:
                        mountPath:
                          description: Path within the container at which the volume
                            should be mounted.  Must not contain ':'.
                          type: string
                        mountPropagation:
                          description: mountPropagation determines how mounts are
                            propagated from the host to container and the other way
                            around. When not set, MountPropagationHostToContainer
                            is used. This field is alpha in 1.8 and can be reworked
                            or removed in a future release.
                          type: string
                        name:
                          description: This must match the Name of a Volume.
                          type: string
                        readOnly:
                          description: Mounted read-only if true, read-write otherwise
                            (false or unspecified). Defaults to false.
                          type: boolean
                        subPath:
                          description: Path within the volume from which the container's
                            volume should be mounted. Defaults to "" (volume's root).
                          type: string
                      required:
                      - name
                      - mountPath
                    type: array
                  workingDir:
                    description: Container's working directory. If not specified,
                      the container runtime's default will be used, which might be
                      configured in the container image. Cannot be updated.
                    type: string
                required:
                - name
              type: array
            externalUrl:
              description: The external URL the Alertmanager instances will be available
                under. This is necessary to generate correct URLs. This is necessary
                if Alertmanager is not served from root of a DNS name.
              type: string
            imagePullSecrets:
              description: An optional list of references to secrets in the same namespace
                to use for pulling prometheus and alertmanager images from registries
                see http://kubernetes.io/docs/user-guide/images#specifying-imagepullsecrets-on-a-pod
              items:
                description: LocalObjectReference contains enough information to let
                  you locate the referenced object inside the same namespace.
                properties:
                  name:
                    description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                    type: string
              type: array
            listenLocal:
              description: ListenLocal makes the Alertmanager server listen on loopback,
                so that it does not bind against the Pod IP. Note this is only for
                the Alertmanager UI, not the gossip communication.
              type: boolean
            logLevel:
              description: Log level for Alertmanager to be configured with.
              type: string
            nodeSelector:
              description: Define which Nodes the Pods are scheduled on.
              type: object
            paused:
              description: If set to true all actions on the underlaying managed objects
                are not goint to be performed, except for delete actions.
              type: boolean
            podMetadata:
              description: ObjectMeta is metadata that all persisted resources must
                have, which includes all objects users must create.
              properties:
                annotations:
                  description: 'Annotations is an unstructured key value map stored
                    with a resource that may be set by external tools to store and
                    retrieve arbitrary metadata. They are not queryable and should
                    be preserved when modifying objects. More info: http://kubernetes.io/docs/user-guide/annotations'
                  type: object
                clusterName:
                  description: The name of the cluster which the object belongs to.
                    This is used to distinguish resources with same name and namespace
                    in different clusters. This field is not set anywhere right now
                    and apiserver is going to ignore it if set in create or update
                    request.
                  type: string
                creationTimestamp:
                  format: date-time
                  type: string
                deletionGracePeriodSeconds:
                  description: Number of seconds allowed for this object to gracefully
                    terminate before it will be removed from the system. Only set
                    when deletionTimestamp is also set. May only be shortened. Read-only.
                  format: int64
                  type: integer
                deletionTimestamp:
                  format: date-time
                  type: string
                finalizers:
                  description: Must be empty before the object is deleted from the
                    registry. Each entry is an identifier for the responsible component
                    that will remove the entry from the list. If the deletionTimestamp
                    of the object is non-nil, entries in this list can only be removed.
                  items:
                    type: string
                  type: array
                generateName:
                  description: |-
                    GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.

                    If this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).

                    Applied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#idempotency
                  type: string
                generation:
                  description: A sequence number representing a specific generation
                    of the desired state. Populated by the system. Read-only.
                  format: int64
                  type: integer
                initializers:
                  description: Initializers tracks the progress of initialization.
                  properties:
                    pending:
                      description: Pending is a list of initializers that must execute
                        in order before this object is visible. When the last pending
                        initializer is removed, and no failing result is set, the
                        initializers struct will be set to nil and the object is considered
                        as initialized and visible to all clients.
                      items:
                        description: Initializer is information about an initializer
                          that has not yet completed.
                        properties:
                          name:
                            description: name of the process that is responsible for
                              initializing this object.
                            type: string
                        required:
                        - name
                      type: array
                    result:
                      description: Status is a return value for calls that don't return
                        other objects.
                      properties:
                        apiVersion:
                          description: 'APIVersion defines the versioned schema of
                            this representation of an object. Servers should convert
                            recognized schemas to the latest internal value, and may
                            reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                          type: string
                        code:
                          description: Suggested HTTP return code for this status,
                            0 if not set.
                          format: int32
                          type: integer
                        details:
                          description: StatusDetails is a set of additional properties
                            that MAY be set by the server to provide additional information
                            about a response. The Reason field of a Status object
                            defines what attributes will be set. Clients must ignore
                            fields that do not match the defined type of each attribute,
                            and should assume that any attribute may be empty, invalid,
                            or under defined.
                          properties:
                            causes:
                              description: The Causes array includes more details
                                associated with the StatusReason failure. Not all
                                StatusReasons may provide detailed causes.
                              items:
                                description: StatusCause provides more information
                                  about an api.Status failure, including cases when
                                  multiple errors are encountered.
                                properties:
                                  field:
                                    description: |-
                                      The field of the resource that has caused this error, as named by its JSON serialization. May include dot and postfix notation for nested attributes. Arrays are zero-indexed.  Fields may appear more than once in an array of causes due to fields having multiple errors. Optional.

                                      Examples:
                                        "name" - the field "name" on the current resource
                                        "items[0].name" - the field "name" on the first array entry in "items"
                                    type: string
                                  message:
                                    description: A human-readable description of the
                                      cause of the error.  This field may be presented
                                      as-is to a reader.
                                    type: string
                                  reason:
                                    description: A machine-readable description of
                                      the cause of the error. If this value is empty
                                      there is no information available.
                                    type: string
                              type: array
                            group:
                              description: The group attribute of the resource associated
                                with the status StatusReason.
                              type: string
                            kind:
                              description: 'The kind attribute of the resource associated
                                with the status StatusReason. On some operations may
                                differ from the requested resource Kind. More info:
                                https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                              type: string
                            name:
                              description: The name attribute of the resource associated
                                with the status StatusReason (when there is a single
                                name which can be described).
                              type: string
                            retryAfterSeconds:
                              description: If specified, the time in seconds before
                                the operation should be retried. Some errors may indicate
                                the client must take an alternate action - for those
                                errors this field may indicate how long to wait before
                                taking the alternate action.
                              format: int32
                              type: integer
                            uid:
                              description: 'UID of the resource. (when there is a
                                single resource which can be described). More info:
                                http://kubernetes.io/docs/user-guide/identifiers#uids'
                              type: string
                        kind:
                          description: 'Kind is a string value representing the REST
                            resource this object represents. Servers may infer this
                            from the endpoint the client submits requests to. Cannot
                            be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                          type: string
                        message:
                          description: A human-readable description of the status
                            of this operation.
                          type: string
                        metadata:
                          description: ListMeta describes metadata that synthetic
                            resources must have, including lists and various status
                            objects. A resource may have only one of {ObjectMeta,
                            ListMeta}.
                          properties:
                            continue:
                              description: continue may be set if the user set a limit
                                on the number of items returned, and indicates that
                                the server has more data available. The value is opaque
                                and may be used to issue another request to the endpoint
                                that served this list to retrieve the next set of
                                available objects. Continuing a list may not be possible
                                if the server configuration has changed or more than
                                a few minutes have passed. The resourceVersion field
                                returned when using this continue value will be identical
                                to the value in the first response.
                              type: string
                            resourceVersion:
                              description: 'String that identifies the server''s internal
                                version of this object that can be used by clients
                                to determine when objects have changed. Value must
                                be treated as opaque by clients and passed unmodified
                                back to the server. Populated by the system. Read-only.
                                More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency'
                              type: string
                            selfLink:
                              description: selfLink is a URL representing this object.
                                Populated by the system. Read-only.
                              type: string
                        reason:
                          description: A machine-readable description of why this
                            operation is in the "Failure" status. If this value is
                            empty there is no information available. A Reason clarifies
                            an HTTP status code but does not override it.
                          type: string
                        status:
                          description: 'Status of the operation. One of: "Success"
                            or "Failure". More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status'
                          type: string
                  required:
                  - pending
                labels:
                  description: 'Map of string keys and values that can be used to
                    organize and categorize (scope and select) objects. May match
                    selectors of replication controllers and services. More info:
                    http://kubernetes.io/docs/user-guide/labels'
                  type: object
                name:
                  description: 'Name must be unique within a namespace. Is required
                    when creating resources, although some resources may allow a client
                    to request the generation of an appropriate name automatically.
                    Name is primarily intended for creation idempotence and configuration
                    definition. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                  type: string
                namespace:
                  description: |-
                    Namespace defines the space within each name must be unique. An empty namespace is equivalent to the "default" namespace, but "default" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.

                    Must be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces
                  type: string
                ownerReferences:
                  description: List of objects depended by this object. If ALL objects
                    in the list have been deleted, this object will be garbage collected.
                    If this object is managed by a controller, then an entry in this
                    list will point to this controller, with the controller field
                    set to true. There cannot be more than one managing controller.
                  items:
                    description: OwnerReference contains enough information to let
                      you identify an owning object. Currently, an owning object must
                      be in the same namespace, so there is no namespace field.
                    properties:
                      apiVersion:
                        description: API version of the referent.
                        type: string
                      blockOwnerDeletion:
                        description: If true, AND if the owner has the "foregroundDeletion"
                          finalizer, then the owner cannot be deleted from the key-value
                          store until this reference is removed. Defaults to false.
                          To set this field, a user needs "delete" permission of the
                          owner, otherwise 422 (Unprocessable Entity) will be returned.
                        type: boolean
                      controller:
                        description: If true, this reference points to the managing
                          controller.
                        type: boolean
                      kind:
                        description: 'Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                        type: string
                      name:
                        description: 'Name of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                        type: string
                      uid:
                        description: 'UID of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                        type: string
                    required:
                    - apiVersion
                    - kind
                    - name
                    - uid
                  type: array
                resourceVersion:
                  description: |-
                    An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.

                    Populated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency
                  type: string
                selfLink:
                  description: SelfLink is a URL representing this object. Populated
                    by the system. Read-only.
                  type: string
                uid:
                  description: |-
                    UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.

                    Populated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids
                  type: string
            replicas:
              description: Size is the expected size of the alertmanager cluster.
                The controller will eventually make the size of the running cluster
                equal to the expected size.
              format: int32
              type: integer
            resources:
              description: ResourceRequirements describes the compute resource requirements.
              properties:
                limits:
                  description: 'Limits describes the maximum amount of compute resources
                    allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                  type: object
                requests:
                  description: 'Requests describes the minimum amount of compute resources
                    required. If Requests is omitted for a container, it defaults
                    to Limits if that is explicitly specified, otherwise to an implementation-defined
                    value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                  type: object
            routePrefix:
              description: The route prefix Alertmanager registers HTTP handlers for.
                This is useful, if using ExternalURL and a proxy is rewriting HTTP
                routes of a request, and the actual ExternalURL is still true, but
                the server serves requests under a different route prefix. For example
                for use with `kubectl proxy`.
              type: string
            secrets:
              description: Secrets is a list of Secrets in the same namespace as the
                Alertmanager object, which shall be mounted into the Alertmanager
                Pods. The Secrets are mounted into /etc/alertmanager/secrets/<secret-name>.
              items:
                type: string
              type: array
            securityContext:
              description: PodSecurityContext holds pod-level security attributes
                and common container settings. Some fields are also present in container.securityContext.  Field
                values of container.securityContext take precedence over field values
                of PodSecurityContext.
              properties:
                fsGroup:
                  description: |-
                    A special supplemental group that applies to all containers in a pod. Some volume types allow the Kubelet to change the ownership of that volume to be owned by the pod:

                    1. The owning GID will be the FSGroup 2. The setgid bit is set (new files created in the volume will be owned by FSGroup) 3. The permission bits are OR'd with rw-rw----

                    If unset, the Kubelet will not modify the ownership and permissions of any volume.
                  format: int64
                  type: integer
                runAsNonRoot:
                  description: Indicates that the container must run as a non-root
                    user. If true, the Kubelet will validate the image at runtime
                    to ensure that it does not run as UID 0 (root) and fail to start
                    the container if it does. If unset or false, no such validation
                    will be performed. May also be set in SecurityContext.  If set
                    in both SecurityContext and PodSecurityContext, the value specified
                    in SecurityContext takes precedence.
                  type: boolean
                runAsUser:
                  description: The UID to run the entrypoint of the container process.
                    Defaults to user specified in image metadata if unspecified. May
                    also be set in SecurityContext.  If set in both SecurityContext
                    and PodSecurityContext, the value specified in SecurityContext
                    takes precedence for that container.
                  format: int64
                  type: integer
                seLinuxOptions:
                  description: SELinuxOptions are the labels to be applied to the
                    container
                  properties:
                    level:
                      description: Level is SELinux level label that applies to the
                        container.
                      type: string
                    role:
                      description: Role is a SELinux role label that applies to the
                        container.
                      type: string
                    type:
                      description: Type is a SELinux type label that applies to the
                        container.
                      type: string
                    user:
                      description: User is a SELinux user label that applies to the
                        container.
                      type: string
                supplementalGroups:
                  description: A list of groups applied to the first process run in
                    each container, in addition to the container's primary GID.  If
                    unspecified, no groups will be added to any container.
                  items:
                    format: int64
                    type: integer
                  type: array
            serviceAccountName:
              description: ServiceAccountName is the name of the ServiceAccount to
                use to run the Prometheus Pods.
              type: string
            storage:
              description: StorageSpec defines the configured storage for a group
                Prometheus servers.
              properties:
                class:
                  description: 'Name of the StorageClass to use when requesting storage
                    provisioning. More info: https://kubernetes.io/docs/user-guide/persistent-volumes/#storageclasses
                    DEPRECATED'
                  type: string
                emptyDir:
                  description: Represents an empty directory for a pod. Empty directory
                    volumes support ownership management and SELinux relabeling.
                  properties:
                    medium:
                      description: 'What type of storage medium should back this directory.
                        The default is "" which means to use the node''s default medium.
                        Must be an empty string (default) or Memory. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir'
                      type: string
                    sizeLimit: {}
                resources:
                  description: ResourceRequirements describes the compute resource
                    requirements.
                  properties:
                    limits:
                      description: 'Limits describes the maximum amount of compute
                        resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                      type: object
                    requests:
                      description: 'Requests describes the minimum amount of compute
                        resources required. If Requests is omitted for a container,
                        it defaults to Limits if that is explicitly specified, otherwise
                        to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                      type: object
                selector:
                  description: A label selector is a label query over a set of resources.
                    The result of matchLabels and matchExpressions are ANDed. An empty
                    label selector matches all objects. A null label selector matches
                    no objects.
                  properties:
                    matchExpressions:
                      description: matchExpressions is a list of label selector requirements.
                        The requirements are ANDed.
                      items:
                        description: A label selector requirement is a selector that
                          contains values, a key, and an operator that relates the
                          key and values.
                        properties:
                          key:
                            description: key is the label key that the selector applies
                              to.
                            type: string
                          operator:
                            description: operator represents a key's relationship
                              to a set of values. Valid operators are In, NotIn, Exists
                              and DoesNotExist.
                            type: string
                          values:
                            description: values is an array of string values. If the
                              operator is In or NotIn, the values array must be non-empty.
                              If the operator is Exists or DoesNotExist, the values
                              array must be empty. This array is replaced during a
                              strategic merge patch.
                            items:
                              type: string
                            type: array
                        required:
                        - key
                        - operator
                      type: array
                    matchLabels:
                      description: matchLabels is a map of {key,value} pairs. A single
                        {key,value} in the matchLabels map is equivalent to an element
                        of matchExpressions, whose key field is "key", the operator
                        is "In", and the values array contains only "value". The requirements
                        are ANDed.
                      type: object
                volumeClaimTemplate:
                  description: PersistentVolumeClaim is a user's request for and claim
                    to a persistent volume
                  properties:
                    apiVersion:
                      description: 'APIVersion defines the versioned schema of this
                        representation of an object. Servers should convert recognized
                        schemas to the latest internal value, and may reject unrecognized
                        values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                      type: string
                    kind:
                      description: 'Kind is a string value representing the REST resource
                        this object represents. Servers may infer this from the endpoint
                        the client submits requests to. Cannot be updated. In CamelCase.
                        More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                      type: string
                    metadata:
                      description: ObjectMeta is metadata that all persisted resources
                        must have, which includes all objects users must create.
                      properties:
                        annotations:
                          description: 'Annotations is an unstructured key value map
                            stored with a resource that may be set by external tools
                            to store and retrieve arbitrary metadata. They are not
                            queryable and should be preserved when modifying objects.
                            More info: http://kubernetes.io/docs/user-guide/annotations'
                          type: object
                        clusterName:
                          description: The name of the cluster which the object belongs
                            to. This is used to distinguish resources with same name
                            and namespace in different clusters. This field is not
                            set anywhere right now and apiserver is going to ignore
                            it if set in create or update request.
                          type: string
                        creationTimestamp:
                          format: date-time
                          type: string
                        deletionGracePeriodSeconds:
                          description: Number of seconds allowed for this object to
                            gracefully terminate before it will be removed from the
                            system. Only set when deletionTimestamp is also set. May
                            only be shortened. Read-only.
                          format: int64
                          type: integer
                        deletionTimestamp:
                          format: date-time
                          type: string
                        finalizers:
                          description: Must be empty before the object is deleted
                            from the registry. Each entry is an identifier for the
                            responsible component that will remove the entry from
                            the list. If the deletionTimestamp of the object is non-nil,
                            entries in this list can only be removed.
                          items:
                            type: string
                          type: array
                        generateName:
                          description: |-
                            GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.

                            If this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).

                            Applied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#idempotency
                          type: string
                        generation:
                          description: A sequence number representing a specific generation
                            of the desired state. Populated by the system. Read-only.
                          format: int64
                          type: integer
                        initializers:
                          description: Initializers tracks the progress of initialization.
                          properties:
                            pending:
                              description: Pending is a list of initializers that
                                must execute in order before this object is visible.
                                When the last pending initializer is removed, and
                                no failing result is set, the initializers struct
                                will be set to nil and the object is considered as
                                initialized and visible to all clients.
                              items:
                                description: Initializer is information about an initializer
                                  that has not yet completed.
                                properties:
                                  name:
                                    description: name of the process that is responsible
                                      for initializing this object.
                                    type: string
                                required:
                                - name
                              type: array
                            result:
                              description: Status is a return value for calls that
                                don't return other objects.
                              properties:
                                apiVersion:
                                  description: 'APIVersion defines the versioned schema
                                    of this representation of an object. Servers should
                                    convert recognized schemas to the latest internal
                                    value, and may reject unrecognized values. More
                                    info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                                  type: string
                                code:
                                  description: Suggested HTTP return code for this
                                    status, 0 if not set.
                                  format: int32
                                  type: integer
                                details:
                                  description: StatusDetails is a set of additional
                                    properties that MAY be set by the server to provide
                                    additional information about a response. The Reason
                                    field of a Status object defines what attributes
                                    will be set. Clients must ignore fields that do
                                    not match the defined type of each attribute,
                                    and should assume that any attribute may be empty,
                                    invalid, or under defined.
                                  properties:
                                    causes:
                                      description: The Causes array includes more
                                        details associated with the StatusReason failure.
                                        Not all StatusReasons may provide detailed
                                        causes.
                                      items:
                                        description: StatusCause provides more information
                                          about an api.Status failure, including cases
                                          when multiple errors are encountered.
                                        properties:
                                          field:
                                            description: |-
                                              The field of the resource that has caused this error, as named by its JSON serialization. May include dot and postfix notation for nested attributes. Arrays are zero-indexed.  Fields may appear more than once in an array of causes due to fields having multiple errors. Optional.

                                              Examples:
                                                "name" - the field "name" on the current resource
                                                "items[0].name" - the field "name" on the first array entry in "items"
                                            type: string
                                          message:
                                            description: A human-readable description
                                              of the cause of the error.  This field
                                              may be presented as-is to a reader.
                                            type: string
                                          reason:
                                            description: A machine-readable description
                                              of the cause of the error. If this value
                                              is empty there is no information available.
                                            type: string
                                      type: array
                                    group:
                                      description: The group attribute of the resource
                                        associated with the status StatusReason.
                                      type: string
                                    kind:
                                      description: 'The kind attribute of the resource
                                        associated with the status StatusReason. On
                                        some operations may differ from the requested
                                        resource Kind. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                      type: string
                                    name:
                                      description: The name attribute of the resource
                                        associated with the status StatusReason (when
                                        there is a single name which can be described).
                                      type: string
                                    retryAfterSeconds:
                                      description: If specified, the time in seconds
                                        before the operation should be retried. Some
                                        errors may indicate the client must take an
                                        alternate action - for those errors this field
                                        may indicate how long to wait before taking
                                        the alternate action.
                                      format: int32
                                      type: integer
                                    uid:
                                      description: 'UID of the resource. (when there
                                        is a single resource which can be described).
                                        More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                                      type: string
                                kind:
                                  description: 'Kind is a string value representing
                                    the REST resource this object represents. Servers
                                    may infer this from the endpoint the client submits
                                    requests to. Cannot be updated. In CamelCase.
                                    More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                  type: string
                                message:
                                  description: A human-readable description of the
                                    status of this operation.
                                  type: string
                                metadata:
                                  description: ListMeta describes metadata that synthetic
                                    resources must have, including lists and various
                                    status objects. A resource may have only one of
                                    {ObjectMeta, ListMeta}.
                                  properties:
                                    continue:
                                      description: continue may be set if the user
                                        set a limit on the number of items returned,
                                        and indicates that the server has more data
                                        available. The value is opaque and may be
                                        used to issue another request to the endpoint
                                        that served this list to retrieve the next
                                        set of available objects. Continuing a list
                                        may not be possible if the server configuration
                                        has changed or more than a few minutes have
                                        passed. The resourceVersion field returned
                                        when using this continue value will be identical
                                        to the value in the first response.
                                      type: string
                                    resourceVersion:
                                      description: 'String that identifies the server''s
                                        internal version of this object that can be
                                        used by clients to determine when objects
                                        have changed. Value must be treated as opaque
                                        by clients and passed unmodified back to the
                                        server. Populated by the system. Read-only.
                                        More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency'
                                      type: string
                                    selfLink:
                                      description: selfLink is a URL representing
                                        this object. Populated by the system. Read-only.
                                      type: string
                                reason:
                                  description: A machine-readable description of why
                                    this operation is in the "Failure" status. If
                                    this value is empty there is no information available.
                                    A Reason clarifies an HTTP status code but does
                                    not override it.
                                  type: string
                                status:
                                  description: 'Status of the operation. One of: "Success"
                                    or "Failure". More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status'
                                  type: string
                          required:
                          - pending
                        labels:
                          description: 'Map of string keys and values that can be
                            used to organize and categorize (scope and select) objects.
                            May match selectors of replication controllers and services.
                            More info: http://kubernetes.io/docs/user-guide/labels'
                          type: object
                        name:
                          description: 'Name must be unique within a namespace. Is
                            required when creating resources, although some resources
                            may allow a client to request the generation of an appropriate
                            name automatically. Name is primarily intended for creation
                            idempotence and configuration definition. Cannot be updated.
                            More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                          type: string
                        namespace:
                          description: |-
                            Namespace defines the space within each name must be unique. An empty namespace is equivalent to the "default" namespace, but "default" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.

                            Must be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces
                          type: string
                        ownerReferences:
                          description: List of objects depended by this object. If
                            ALL objects in the list have been deleted, this object
                            will be garbage collected. If this object is managed by
                            a controller, then an entry in this list will point to
                            this controller, with the controller field set to true.
                            There cannot be more than one managing controller.
                          items:
                            description: OwnerReference contains enough information
                              to let you identify an owning object. Currently, an
                              owning object must be in the same namespace, so there
                              is no namespace field.
                            properties:
                              apiVersion:
                                description: API version of the referent.
                                type: string
                              blockOwnerDeletion:
                                description: If true, AND if the owner has the "foregroundDeletion"
                                  finalizer, then the owner cannot be deleted from
                                  the key-value store until this reference is removed.
                                  Defaults to false. To set this field, a user needs
                                  "delete" permission of the owner, otherwise 422
                                  (Unprocessable Entity) will be returned.
                                type: boolean
                              controller:
                                description: If true, this reference points to the
                                  managing controller.
                                type: boolean
                              kind:
                                description: 'Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                type: string
                              name:
                                description: 'Name of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                                type: string
                              uid:
                                description: 'UID of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                                type: string
                            required:
                            - apiVersion
                            - kind
                            - name
                            - uid
                          type: array
                        resourceVersion:
                          description: |-
                            An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.

                            Populated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency
                          type: string
                        selfLink:
                          description: SelfLink is a URL representing this object.
                            Populated by the system. Read-only.
                          type: string
                        uid:
                          description: |-
                            UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.

                            Populated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids
                          type: string
                    spec:
                      description: PersistentVolumeClaimSpec describes the common
                        attributes of storage devices and allows a Source for provider-specific
                        attributes
                      properties:
                        accessModes:
                          description: 'AccessModes contains the desired access modes
                            the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1'
                          items:
                            type: string
                          type: array
                        resources:
                          description: ResourceRequirements describes the compute
                            resource requirements.
                          properties:
                            limits:
                              description: 'Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                              type: object
                            requests:
                              description: 'Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                              type: object
                        selector:
                          description: A label selector is a label query over a set
                            of resources. The result of matchLabels and matchExpressions
                            are ANDed. An empty label selector matches all objects.
                            A null label selector matches no objects.
                          properties:
                            matchExpressions:
                              description: matchExpressions is a list of label selector
                                requirements. The requirements are ANDed.
                              items:
                                description: A label selector requirement is a selector
                                  that contains values, a key, and an operator that
                                  relates the key and values.
                                properties:
                                  key:
                                    description: key is the label key that the selector
                                      applies to.
                                    type: string
                                  operator:
                                    description: operator represents a key's relationship
                                      to a set of values. Valid operators are In,
                                      NotIn, Exists and DoesNotExist.
                                    type: string
                                  values:
                                    description: values is an array of string values.
                                      If the operator is In or NotIn, the values array
                                      must be non-empty. If the operator is Exists
                                      or DoesNotExist, the values array must be empty.
                                      This array is replaced during a strategic merge
                                      patch.
                                    items:
                                      type: string
                                    type: array
                                required:
                                - key
                                - operator
                              type: array
                            matchLabels:
                              description: matchLabels is a map of {key,value} pairs.
                                A single {key,value} in the matchLabels map is equivalent
                                to an element of matchExpressions, whose key field
                                is "key", the operator is "In", and the values array
                                contains only "value". The requirements are ANDed.
                              type: object
                        storageClassName:
                          description: 'Name of the StorageClass required by the claim.
                            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1'
                          type: string
                        volumeMode:
                          description: volumeMode defines what type of volume is required
                            by the claim. Value of Filesystem is implied when not
                            included in claim spec. This is an alpha feature and may
                            change in the future.
                          type: string
                        volumeName:
                          description: VolumeName is the binding reference to the
                            PersistentVolume backing this claim.
                          type: string
                    status:
                      description: PersistentVolumeClaimStatus is the current status
                        of a persistent volume claim.
                      properties:
                        accessModes:
                          description: 'AccessModes contains the actual access modes
                            the volume backing the PVC has. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1'
                          items:
                            type: string
                          type: array
                        capacity:
                          description: Represents the actual resources of the underlying
                            volume.
                          type: object
                        conditions:
                          description: Current Condition of persistent volume claim.
                            If underlying persistent volume is being resized then
                            the Condition will be set to 'ResizeStarted'.
                          items:
                            description: PersistentVolumeClaimCondition contails details
                              about state of pvc
                            properties:
                              lastProbeTime:
                                format: date-time
                                type: string
                              lastTransitionTime:
                                format: date-time
                                type: string
                              message:
                                description: Human-readable message indicating details
                                  about last transition.
                                type: string
                              reason:
                                description: Unique, this should be a short, machine
                                  understandable string that gives the reason for
                                  condition's last transition. If it reports "ResizeStarted"
                                  that means the underlying persistent volume is being
                                  resized.
                                type: string
                              status:
                                type: string
                              type:
                                type: string
                            required:
                            - type
                            - status
                          type: array
                        phase:
                          description: Phase represents the current phase of PersistentVolumeClaim.
                          type: string
            tolerations:
              description: If specified, the pod's tolerations.
              items:
                description: The pod this Toleration is attached to tolerates any
                  taint that matches the triple <key,value,effect> using the matching
                  operator <operator>.
                properties:
                  effect:
                    description: Effect indicates the taint effect to match. Empty
                      means match all taint effects. When specified, allowed values
                      are NoSchedule, PreferNoSchedule and NoExecute.
                    type: string
                  key:
                    description: Key is the taint key that the toleration applies
                      to. Empty means match all taint keys. If the key is empty, operator
                      must be Exists; this combination means to match all values and
                      all keys.
                    type: string
                  operator:
                    description: Operator represents a key's relationship to the value.
                      Valid operators are Exists and Equal. Defaults to Equal. Exists
                      is equivalent to wildcard for value, so that a pod can tolerate
                      all taints of a particular category.
                    type: string
                  tolerationSeconds:
                    description: TolerationSeconds represents the period of time the
                      toleration (which must be of effect NoExecute, otherwise this
                      field is ignored) tolerates the taint. By default, it is not
                      set, which means tolerate the taint forever (do not evict).
                      Zero and negative values will be treated as 0 (evict immediately)
                      by the system.
                    format: int64
                    type: integer
                  value:
                    description: Value is the taint value the toleration matches to.
                      If the operator is Exists, the value should be empty, otherwise
                      just a regular string.
                    type: string
              type: array
            version:
              description: Version the cluster should be on.
              type: string
        status:
          description: 'Most recent observed status of the Alertmanager cluster. Read-only.
            Not included when requesting from the apiserver, only from the Prometheus
            Operator API itself. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status'
          properties:
            availableReplicas:
              description: Total number of available pods (ready for at least minReadySeconds)
                targeted by this Alertmanager cluster.
              format: int32
              type: integer
            paused:
              description: Represents whether any actions on the underlaying managed
                objects are being performed. Only delete actions will be performed.
              type: boolean
            replicas:
              description: Total number of non-terminated pods targeted by this Alertmanager
                cluster (their labels match the selector).
              format: int32
              type: integer
            unavailableReplicas:
              description: Total number of unavailable pods targeted by this Alertmanager
                cluster.
              format: int32
              type: integer
            updatedReplicas:
              description: Total number of non-terminated pods targeted by this Alertmanager
                cluster that have the desired version spec.
              format: int32
              type: integer
          required:
          - paused
          - replicas
          - updatedReplicas
          - availableReplicas
          - unavailableReplicas
      required:
      - spec
  version: v1
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: null
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  creationTimestamp: null
  name: prometheuses.monitoring.coreos.com
spec:
  group: monitoring.coreos.com
  names:
    kind: Prometheus
    plural: prometheuses
  scope: Namespaced
  validation:
    openAPIV3Schema:
      description: Prometheus defines a Prometheus deployment.
      properties:
        apiVersion:
          description: 'APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
          type: string
        kind:
          description: 'Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the client
            submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
          type: string
        spec:
          description: 'Specification of the desired behavior of the Prometheus cluster.
            More info: https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status'
          properties:
            additionalScrapeConfigs:
              description: SecretKeySelector selects a key of a Secret.
              properties:
                key:
                  description: The key of the secret to select from.  Must be a valid
                    secret key.
                  type: string
                name:
                  description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                  type: string
                optional:
                  description: Specify whether the Secret or it's key must be defined
                  type: boolean
              required:
              - key
            affinity:
              description: Affinity is a group of affinity scheduling rules.
              properties:
                nodeAffinity:
                  description: Node affinity is a group of node affinity scheduling
                    rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the affinity expressions specified by this field,
                        but it may choose a node that violates one or more of the
                        expressions. The node that is most preferred is the one with
                        the greatest sum of weights, i.e. for each node that meets
                        all of the scheduling requirements (resource request, requiredDuringScheduling
                        affinity expressions, etc.), compute a sum by iterating through
                        the elements of this field and adding "weight" to the sum
                        if the node matches the corresponding matchExpressions; the
                        node(s) with the highest sum are the most preferred.
                      items:
                        description: An empty preferred scheduling term matches all
                          objects with implicit weight 0 (i.e. it's a no-op). A null
                          preferred scheduling term matches no objects (i.e. is also
                          a no-op).
                        properties:
                          preference:
                            description: A null or empty node selector term matches
                              no objects.
                            properties:
                              matchExpressions:
                                description: Required. A list of node selector requirements.
                                  The requirements are ANDed.
                                items:
                                  description: A node selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: The label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: Represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists, DoesNotExist. Gt, and Lt.
                                      type: string
                                    values:
                                      description: An array of string values. If the
                                        operator is In or NotIn, the values array
                                        must be non-empty. If the operator is Exists
                                        or DoesNotExist, the values array must be
                                        empty. If the operator is Gt or Lt, the values
                                        array must have a single element, which will
                                        be interpreted as an integer. This array is
                                        replaced during a strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                            required:
                            - matchExpressions
                          weight:
                            description: Weight associated with matching the corresponding
                              nodeSelectorTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - preference
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: A node selector represents the union of the results
                        of one or more label queries over a set of nodes; that is,
                        it represents the OR of the selectors represented by the node
                        selector terms.
                      properties:
                        nodeSelectorTerms:
                          description: Required. A list of node selector terms. The
                            terms are ORed.
                          items:
                            description: A null or empty node selector term matches
                              no objects.
                            properties:
                              matchExpressions:
                                description: Required. A list of node selector requirements.
                                  The requirements are ANDed.
                                items:
                                  description: A node selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: The label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: Represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists, DoesNotExist. Gt, and Lt.
                                      type: string
                                    values:
                                      description: An array of string values. If the
                                        operator is In or NotIn, the values array
                                        must be non-empty. If the operator is Exists
                                        or DoesNotExist, the values array must be
                                        empty. If the operator is Gt or Lt, the values
                                        array must have a single element, which will
                                        be interpreted as an integer. This array is
                                        replaced during a strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                            required:
                            - matchExpressions
                          type: array
                      required:
                      - nodeSelectorTerms
                podAffinity:
                  description: Pod affinity is a group of inter pod affinity scheduling
                    rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the affinity expressions specified by this field,
                        but it may choose a node that violates one or more of the
                        expressions. The node that is most preferred is the one with
                        the greatest sum of weights, i.e. for each node that meets
                        all of the scheduling requirements (resource request, requiredDuringScheduling
                        affinity expressions, etc.), compute a sum by iterating through
                        the elements of this field and adding "weight" to the sum
                        if the node has pods which matches the corresponding podAffinityTerm;
                        the node(s) with the highest sum are the most preferred.
                      items:
                        description: The weights of all of the matched WeightedPodAffinityTerm
                          fields are added per-node to find the most preferred node(s)
                        properties:
                          podAffinityTerm:
                            description: Defines a set of pods (namely those matching
                              the labelSelector relative to the given namespace(s))
                              that this pod should be co-located (affinity) or not
                              co-located (anti-affinity) with, where co-located is
                              defined as running on a node whose value of the label
                              with key <topologyKey> matches that of any node on which
                              a pod of the set of pods is running
                            properties:
                              labelSelector:
                                description: A label selector is a label query over
                                  a set of resources. The result of matchLabels and
                                  matchExpressions are ANDed. An empty label selector
                                  matches all objects. A null label selector matches
                                  no objects.
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label
                                      selector requirements. The requirements are
                                      ANDed.
                                    items:
                                      description: A label selector requirement is
                                        a selector that contains values, a key, and
                                        an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the
                                            selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's
                                            relationship to a set of values. Valid
                                            operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string
                                            values. If the operator is In or NotIn,
                                            the values array must be non-empty. If
                                            the operator is Exists or DoesNotExist,
                                            the values array must be empty. This array
                                            is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                      - key
                                      - operator
                                    type: array
                                  matchLabels:
                                    description: matchLabels is a map of {key,value}
                                      pairs. A single {key,value} in the matchLabels
                                      map is equivalent to an element of matchExpressions,
                                      whose key field is "key", the operator is "In",
                                      and the values array contains only "value".
                                      The requirements are ANDed.
                                    type: object
                              namespaces:
                                description: namespaces specifies which namespaces
                                  the labelSelector applies to (matches against);
                                  null or empty list means "this pod's namespace"
                                items:
                                  type: string
                                type: array
                              topologyKey:
                                description: This pod should be co-located (affinity)
                                  or not co-located (anti-affinity) with the pods
                                  matching the labelSelector in the specified namespaces,
                                  where co-located is defined as running on a node
                                  whose value of the label with key topologyKey matches
                                  that of any node on which any of the selected pods
                                  is running. Empty topologyKey is not allowed.
                                type: string
                            required:
                            - topologyKey
                          weight:
                            description: weight associated with matching the corresponding
                              podAffinityTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - podAffinityTerm
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: If the affinity requirements specified by this
                        field are not met at scheduling time, the pod will not be
                        scheduled onto the node. If the affinity requirements specified
                        by this field cease to be met at some point during pod execution
                        (e.g. due to a pod label update), the system may or may not
                        try to eventually evict the pod from its node. When there
                        are multiple elements, the lists of nodes corresponding to
                        each podAffinityTerm are intersected, i.e. all terms must
                        be satisfied.
                      items:
                        description: Defines a set of pods (namely those matching
                          the labelSelector relative to the given namespace(s)) that
                          this pod should be co-located (affinity) or not co-located
                          (anti-affinity) with, where co-located is defined as running
                          on a node whose value of the label with key <topologyKey>
                          matches that of any node on which a pod of the set of pods
                          is running
                        properties:
                          labelSelector:
                            description: A label selector is a label query over a
                              set of resources. The result of matchLabels and matchExpressions
                              are ANDed. An empty label selector matches all objects.
                              A null label selector matches no objects.
                            properties:
                              matchExpressions:
                                description: matchExpressions is a list of label selector
                                  requirements. The requirements are ANDed.
                                items:
                                  description: A label selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: key is the label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: operator represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists and DoesNotExist.
                                      type: string
                                    values:
                                      description: values is an array of string values.
                                        If the operator is In or NotIn, the values
                                        array must be non-empty. If the operator is
                                        Exists or DoesNotExist, the values array must
                                        be empty. This array is replaced during a
                                        strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                              matchLabels:
                                description: matchLabels is a map of {key,value} pairs.
                                  A single {key,value} in the matchLabels map is equivalent
                                  to an element of matchExpressions, whose key field
                                  is "key", the operator is "In", and the values array
                                  contains only "value". The requirements are ANDed.
                                type: object
                          namespaces:
                            description: namespaces specifies which namespaces the
                              labelSelector applies to (matches against); null or
                              empty list means "this pod's namespace"
                            items:
                              type: string
                            type: array
                          topologyKey:
                            description: This pod should be co-located (affinity)
                              or not co-located (anti-affinity) with the pods matching
                              the labelSelector in the specified namespaces, where
                              co-located is defined as running on a node whose value
                              of the label with key topologyKey matches that of any
                              node on which any of the selected pods is running. Empty
                              topologyKey is not allowed.
                            type: string
                        required:
                        - topologyKey
                      type: array
                podAntiAffinity:
                  description: Pod anti affinity is a group of inter pod anti affinity
                    scheduling rules.
                  properties:
                    preferredDuringSchedulingIgnoredDuringExecution:
                      description: The scheduler will prefer to schedule pods to nodes
                        that satisfy the anti-affinity expressions specified by this
                        field, but it may choose a node that violates one or more
                        of the expressions. The node that is most preferred is the
                        one with the greatest sum of weights, i.e. for each node that
                        meets all of the scheduling requirements (resource request,
                        requiredDuringScheduling anti-affinity expressions, etc.),
                        compute a sum by iterating through the elements of this field
                        and adding "weight" to the sum if the node has pods which
                        matches the corresponding podAffinityTerm; the node(s) with
                        the highest sum are the most preferred.
                      items:
                        description: The weights of all of the matched WeightedPodAffinityTerm
                          fields are added per-node to find the most preferred node(s)
                        properties:
                          podAffinityTerm:
                            description: Defines a set of pods (namely those matching
                              the labelSelector relative to the given namespace(s))
                              that this pod should be co-located (affinity) or not
                              co-located (anti-affinity) with, where co-located is
                              defined as running on a node whose value of the label
                              with key <topologyKey> matches that of any node on which
                              a pod of the set of pods is running
                            properties:
                              labelSelector:
                                description: A label selector is a label query over
                                  a set of resources. The result of matchLabels and
                                  matchExpressions are ANDed. An empty label selector
                                  matches all objects. A null label selector matches
                                  no objects.
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label
                                      selector requirements. The requirements are
                                      ANDed.
                                    items:
                                      description: A label selector requirement is
                                        a selector that contains values, a key, and
                                        an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the
                                            selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's
                                            relationship to a set of values. Valid
                                            operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string
                                            values. If the operator is In or NotIn,
                                            the values array must be non-empty. If
                                            the operator is Exists or DoesNotExist,
                                            the values array must be empty. This array
                                            is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                      - key
                                      - operator
                                    type: array
                                  matchLabels:
                                    description: matchLabels is a map of {key,value}
                                      pairs. A single {key,value} in the matchLabels
                                      map is equivalent to an element of matchExpressions,
                                      whose key field is "key", the operator is "In",
                                      and the values array contains only "value".
                                      The requirements are ANDed.
                                    type: object
                              namespaces:
                                description: namespaces specifies which namespaces
                                  the labelSelector applies to (matches against);
                                  null or empty list means "this pod's namespace"
                                items:
                                  type: string
                                type: array
                              topologyKey:
                                description: This pod should be co-located (affinity)
                                  or not co-located (anti-affinity) with the pods
                                  matching the labelSelector in the specified namespaces,
                                  where co-located is defined as running on a node
                                  whose value of the label with key topologyKey matches
                                  that of any node on which any of the selected pods
                                  is running. Empty topologyKey is not allowed.
                                type: string
                            required:
                            - topologyKey
                          weight:
                            description: weight associated with matching the corresponding
                              podAffinityTerm, in the range 1-100.
                            format: int32
                            type: integer
                        required:
                        - weight
                        - podAffinityTerm
                      type: array
                    requiredDuringSchedulingIgnoredDuringExecution:
                      description: If the anti-affinity requirements specified by
                        this field are not met at scheduling time, the pod will not
                        be scheduled onto the node. If the anti-affinity requirements
                        specified by this field cease to be met at some point during
                        pod execution (e.g. due to a pod label update), the system
                        may or may not try to eventually evict the pod from its node.
                        When there are multiple elements, the lists of nodes corresponding
                        to each podAffinityTerm are intersected, i.e. all terms must
                        be satisfied.
                      items:
                        description: Defines a set of pods (namely those matching
                          the labelSelector relative to the given namespace(s)) that
                          this pod should be co-located (affinity) or not co-located
                          (anti-affinity) with, where co-located is defined as running
                          on a node whose value of the label with key <topologyKey>
                          matches that of any node on which a pod of the set of pods
                          is running
                        properties:
                          labelSelector:
                            description: A label selector is a label query over a
                              set of resources. The result of matchLabels and matchExpressions
                              are ANDed. An empty label selector matches all objects.
                              A null label selector matches no objects.
                            properties:
                              matchExpressions:
                                description: matchExpressions is a list of label selector
                                  requirements. The requirements are ANDed.
                                items:
                                  description: A label selector requirement is a selector
                                    that contains values, a key, and an operator that
                                    relates the key and values.
                                  properties:
                                    key:
                                      description: key is the label key that the selector
                                        applies to.
                                      type: string
                                    operator:
                                      description: operator represents a key's relationship
                                        to a set of values. Valid operators are In,
                                        NotIn, Exists and DoesNotExist.
                                      type: string
                                    values:
                                      description: values is an array of string values.
                                        If the operator is In or NotIn, the values
                                        array must be non-empty. If the operator is
                                        Exists or DoesNotExist, the values array must
                                        be empty. This array is replaced during a
                                        strategic merge patch.
                                      items:
                                        type: string
                                      type: array
                                  required:
                                  - key
                                  - operator
                                type: array
                              matchLabels:
                                description: matchLabels is a map of {key,value} pairs.
                                  A single {key,value} in the matchLabels map is equivalent
                                  to an element of matchExpressions, whose key field
                                  is "key", the operator is "In", and the values array
                                  contains only "value". The requirements are ANDed.
                                type: object
                          namespaces:
                            description: namespaces specifies which namespaces the
                              labelSelector applies to (matches against); null or
                              empty list means "this pod's namespace"
                            items:
                              type: string
                            type: array
                          topologyKey:
                            description: This pod should be co-located (affinity)
                              or not co-located (anti-affinity) with the pods matching
                              the labelSelector in the specified namespaces, where
                              co-located is defined as running on a node whose value
                              of the label with key topologyKey matches that of any
                              node on which any of the selected pods is running. Empty
                              topologyKey is not allowed.
                            type: string
                        required:
                        - topologyKey
                      type: array
            alerting:
              description: AlertingSpec defines parameters for alerting configuration
                of Prometheus servers.
              properties:
                alertmanagers:
                  description: AlertmanagerEndpoints Prometheus should fire alerts
                    against.
                  items:
                    description: AlertmanagerEndpoints defines a selection of a single
                      Endpoints object containing alertmanager IPs to fire alerts
                      against.
                    properties:
                      bearerTokenFile:
                        description: BearerTokenFile to read from filesystem to use
                          when authenticating to Alertmanager.
                        type: string
                      name:
                        description: Name of Endpoints object in Namespace.
                        type: string
                      namespace:
                        description: Namespace of Endpoints object.
                        type: string
                      pathPrefix:
                        description: Prefix for the HTTP path alerts are pushed to.
                        type: string
                      port: {}
                      scheme:
                        description: Scheme to use when firing alerts.
                        type: string
                      tlsConfig:
                        description: TLSConfig specifies TLS configuration parameters.
                        properties:
                          caFile:
                            description: The CA cert to use for the targets.
                            type: string
                          certFile:
                            description: The client cert file for the targets.
                            type: string
                          insecureSkipVerify:
                            description: Disable target certificate validation.
                            type: boolean
                          keyFile:
                            description: The client key file for the targets.
                            type: string
                          serverName:
                            description: Used to verify the hostname for the targets.
                            type: string
                    required:
                    - namespace
                    - name
                    - port
                  type: array
              required:
              - alertmanagers
            baseImage:
              description: Base image to use for a Prometheus deployment.
              type: string
            containers:
              description: Containers allows injecting additional containers. This
                is meant to allow adding an authentication proxy to a Prometheus pod.
              items:
                description: A single application container that you want to run within
                  a pod.
                properties:
                  args:
                    description: 'Arguments to the entrypoint. The docker image''s
                      CMD is used if this is not provided. Variable references \$(VAR_NAME)
                      are expanded using the container''s environment. If a variable
                      cannot be resolved, the reference in the input string will be
                      unchanged. The \$(VAR_NAME) syntax can be escaped with a double
                      $$, ie: $\$(VAR_NAME). Escaped references will never be expanded,
                      regardless of whether the variable exists or not. Cannot be
                      updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell'
                    items:
                      type: string
                    type: array
                  command:
                    description: 'Entrypoint array. Not executed within a shell. The
                      docker image''s ENTRYPOINT is used if this is not provided.
                      Variable references \$(VAR_NAME) are expanded using the container''s
                      environment. If a variable cannot be resolved, the reference
                      in the input string will be unchanged. The \$(VAR_NAME) syntax
                      can be escaped with a double $$, ie: $\$(VAR_NAME). Escaped references
                      will never be expanded, regardless of whether the variable exists
                      or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell'
                    items:
                      type: string
                    type: array
                  env:
                    description: List of environment variables to set in the container.
                      Cannot be updated.
                    items:
                      description: EnvVar represents an environment variable present
                        in a Container.
                      properties:
                        name:
                          description: Name of the environment variable. Must be a
                            C_IDENTIFIER.
                          type: string
                        value:
                          description: 'Variable references \$(VAR_NAME) are expanded
                            using the previous defined environment variables in the
                            container and any service environment variables. If a
                            variable cannot be resolved, the reference in the input
                            string will be unchanged. The \$(VAR_NAME) syntax can be
                            escaped with a double $$, ie: $\$(VAR_NAME). Escaped references
                            will never be expanded, regardless of whether the variable
                            exists or not. Defaults to "".'
                          type: string
                        valueFrom:
                          description: EnvVarSource represents a source for the value
                            of an EnvVar.
                          properties:
                            configMapKeyRef:
                              description: Selects a key from a ConfigMap.
                              properties:
                                key:
                                  description: The key to select.
                                  type: string
                                name:
                                  description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                                  type: string
                                optional:
                                  description: Specify whether the ConfigMap or it's
                                    key must be defined
                                  type: boolean
                              required:
                              - key
                            fieldRef:
                              description: ObjectFieldSelector selects an APIVersioned
                                field of an object.
                              properties:
                                apiVersion:
                                  description: Version of the schema the FieldPath
                                    is written in terms of, defaults to "v1".
                                  type: string
                                fieldPath:
                                  description: Path of the field to select in the
                                    specified API version.
                                  type: string
                              required:
                              - fieldPath
                            resourceFieldRef:
                              description: ResourceFieldSelector represents container
                                resources (cpu, memory) and their output format
                              properties:
                                containerName:
                                  description: 'Container name: required for volumes,
                                    optional for env vars'
                                  type: string
                                divisor: {}
                                resource:
                                  description: 'Required: resource to select'
                                  type: string
                              required:
                              - resource
                            secretKeyRef:
                              description: SecretKeySelector selects a key of a Secret.
                              properties:
                                key:
                                  description: The key of the secret to select from.  Must
                                    be a valid secret key.
                                  type: string
                                name:
                                  description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                                  type: string
                                optional:
                                  description: Specify whether the Secret or it's
                                    key must be defined
                                  type: boolean
                              required:
                              - key
                      required:
                      - name
                    type: array
                  envFrom:
                    description: List of sources to populate environment variables
                      in the container. The keys defined within a source must be a
                      C_IDENTIFIER. All invalid keys will be reported as an event
                      when the container is starting. When a key exists in multiple
                      sources, the value associated with the last source will take
                      precedence. Values defined by an Env with a duplicate key will
                      take precedence. Cannot be updated.
                    items:
                      description: EnvFromSource represents the source of a set of
                        ConfigMaps
                      properties:
                        configMapRef:
                          description: |-
                            ConfigMapEnvSource selects a ConfigMap to populate the environment variables with.

                            The contents of the target ConfigMap's Data field will represent the key-value pairs as environment variables.
                          properties:
                            name:
                              description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                              type: string
                            optional:
                              description: Specify whether the ConfigMap must be defined
                              type: boolean
                        prefix:
                          description: An optional identifer to prepend to each key
                            in the ConfigMap. Must be a C_IDENTIFIER.
                          type: string
                        secretRef:
                          description: |-
                            SecretEnvSource selects a Secret to populate the environment variables with.

                            The contents of the target Secret's Data field will represent the key-value pairs as environment variables.
                          properties:
                            name:
                              description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                              type: string
                            optional:
                              description: Specify whether the Secret must be defined
                              type: boolean
                    type: array
                  image:
                    description: 'Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images
                      This field is optional to allow higher level config management
                      to default or override container images in workload controllers
                      like Deployments and StatefulSets.'
                    type: string
                  imagePullPolicy:
                    description: 'Image pull policy. One of Always, Never, IfNotPresent.
                      Defaults to Always if :latest tag is specified, or IfNotPresent
                      otherwise. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images'
                    type: string
                  lifecycle:
                    description: Lifecycle describes actions that the management system
                      should take in response to container lifecycle events. For the
                      PostStart and PreStop lifecycle handlers, management of the
                      container blocks until the action is complete, unless the container
                      process fails, in which case the handler is aborted.
                    properties:
                      postStart:
                        description: Handler defines a specific action that should
                          be taken
                        properties:
                          exec:
                            description: ExecAction describes a "run in container"
                              action.
                            properties:
                              command:
                                description: Command is the command line to execute
                                  inside the container, the working directory for
                                  the command  is root ('/') in the container's filesystem.
                                  The command is simply exec'd, it is not run inside
                                  a shell, so traditional shell instructions ('|',
                                  etc) won't work. To use a shell, you need to explicitly
                                  call out to that shell. Exit status of 0 is treated
                                  as live/healthy and non-zero is unhealthy.
                                items:
                                  type: string
                                type: array
                          httpGet:
                            description: HTTPGetAction describes an action based on
                              HTTP Get requests.
                            properties:
                              host:
                                description: Host name to connect to, defaults to
                                  the pod IP. You probably want to set "Host" in httpHeaders
                                  instead.
                                type: string
                              httpHeaders:
                                description: Custom headers to set in the request.
                                  HTTP allows repeated headers.
                                items:
                                  description: HTTPHeader describes a custom header
                                    to be used in HTTP probes
                                  properties:
                                    name:
                                      description: The header field name
                                      type: string
                                    value:
                                      description: The header field value
                                      type: string
                                  required:
                                  - name
                                  - value
                                type: array
                              path:
                                description: Path to access on the HTTP server.
                                type: string
                              port: {}
                              scheme:
                                description: Scheme to use for connecting to the host.
                                  Defaults to HTTP.
                                type: string
                            required:
                            - port
                          tcpSocket:
                            description: TCPSocketAction describes an action based
                              on opening a socket
                            properties:
                              host:
                                description: 'Optional: Host name to connect to, defaults
                                  to the pod IP.'
                                type: string
                              port: {}
                            required:
                            - port
                      preStop:
                        description: Handler defines a specific action that should
                          be taken
                        properties:
                          exec:
                            description: ExecAction describes a "run in container"
                              action.
                            properties:
                              command:
                                description: Command is the command line to execute
                                  inside the container, the working directory for
                                  the command  is root ('/') in the container's filesystem.
                                  The command is simply exec'd, it is not run inside
                                  a shell, so traditional shell instructions ('|',
                                  etc) won't work. To use a shell, you need to explicitly
                                  call out to that shell. Exit status of 0 is treated
                                  as live/healthy and non-zero is unhealthy.
                                items:
                                  type: string
                                type: array
                          httpGet:
                            description: HTTPGetAction describes an action based on
                              HTTP Get requests.
                            properties:
                              host:
                                description: Host name to connect to, defaults to
                                  the pod IP. You probably want to set "Host" in httpHeaders
                                  instead.
                                type: string
                              httpHeaders:
                                description: Custom headers to set in the request.
                                  HTTP allows repeated headers.
                                items:
                                  description: HTTPHeader describes a custom header
                                    to be used in HTTP probes
                                  properties:
                                    name:
                                      description: The header field name
                                      type: string
                                    value:
                                      description: The header field value
                                      type: string
                                  required:
                                  - name
                                  - value
                                type: array
                              path:
                                description: Path to access on the HTTP server.
                                type: string
                              port: {}
                              scheme:
                                description: Scheme to use for connecting to the host.
                                  Defaults to HTTP.
                                type: string
                            required:
                            - port
                          tcpSocket:
                            description: TCPSocketAction describes an action based
                              on opening a socket
                            properties:
                              host:
                                description: 'Optional: Host name to connect to, defaults
                                  to the pod IP.'
                                type: string
                              port: {}
                            required:
                            - port
                  livenessProbe:
                    description: Probe describes a health check to be performed against
                      a container to determine whether it is alive or ready to receive
                      traffic.
                    properties:
                      exec:
                        description: ExecAction describes a "run in container" action.
                        properties:
                          command:
                            description: Command is the command line to execute inside
                              the container, the working directory for the command  is
                              root ('/') in the container's filesystem. The command
                              is simply exec'd, it is not run inside a shell, so traditional
                              shell instructions ('|', etc) won't work. To use a shell,
                              you need to explicitly call out to that shell. Exit
                              status of 0 is treated as live/healthy and non-zero
                              is unhealthy.
                            items:
                              type: string
                            type: array
                      failureThreshold:
                        description: Minimum consecutive failures for the probe to
                          be considered failed after having succeeded. Defaults to
                          3. Minimum value is 1.
                        format: int32
                        type: integer
                      httpGet:
                        description: HTTPGetAction describes an action based on HTTP
                          Get requests.
                        properties:
                          host:
                            description: Host name to connect to, defaults to the
                              pod IP. You probably want to set "Host" in httpHeaders
                              instead.
                            type: string
                          httpHeaders:
                            description: Custom headers to set in the request. HTTP
                              allows repeated headers.
                            items:
                              description: HTTPHeader describes a custom header to
                                be used in HTTP probes
                              properties:
                                name:
                                  description: The header field name
                                  type: string
                                value:
                                  description: The header field value
                                  type: string
                              required:
                              - name
                              - value
                            type: array
                          path:
                            description: Path to access on the HTTP server.
                            type: string
                          port: {}
                          scheme:
                            description: Scheme to use for connecting to the host.
                              Defaults to HTTP.
                            type: string
                        required:
                        - port
                      initialDelaySeconds:
                        description: 'Number of seconds after the container has started
                          before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                      periodSeconds:
                        description: How often (in seconds) to perform the probe.
                          Default to 10 seconds. Minimum value is 1.
                        format: int32
                        type: integer
                      successThreshold:
                        description: Minimum consecutive successes for the probe to
                          be considered successful after having failed. Defaults to
                          1. Must be 1 for liveness. Minimum value is 1.
                        format: int32
                        type: integer
                      tcpSocket:
                        description: TCPSocketAction describes an action based on
                          opening a socket
                        properties:
                          host:
                            description: 'Optional: Host name to connect to, defaults
                              to the pod IP.'
                            type: string
                          port: {}
                        required:
                        - port
                      timeoutSeconds:
                        description: 'Number of seconds after which the probe times
                          out. Defaults to 1 second. Minimum value is 1. More info:
                          https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                  name:
                    description: Name of the container specified as a DNS_LABEL. Each
                      container in a pod must have a unique name (DNS_LABEL). Cannot
                      be updated.
                    type: string
                  ports:
                    description: List of ports to expose from the container. Exposing
                      a port here gives the system additional information about the
                      network connections a container uses, but is primarily informational.
                      Not specifying a port here DOES NOT prevent that port from being
                      exposed. Any port which is listening on the default "0.0.0.0"
                      address inside a container will be accessible from the network.
                      Cannot be updated.
                    items:
                      description: ContainerPort represents a network port in a single
                        container.
                      properties:
                        containerPort:
                          description: Number of port to expose on the pod's IP address.
                            This must be a valid port number, 0 < x < 65536.
                          format: int32
                          type: integer
                        hostIP:
                          description: What host IP to bind the external port to.
                          type: string
                        hostPort:
                          description: Number of port to expose on the host. If specified,
                            this must be a valid port number, 0 < x < 65536. If HostNetwork
                            is specified, this must match ContainerPort. Most containers
                            do not need this.
                          format: int32
                          type: integer
                        name:
                          description: If specified, this must be an IANA_SVC_NAME
                            and unique within the pod. Each named port in a pod must
                            have a unique name. Name for the port that can be referred
                            to by services.
                          type: string
                        protocol:
                          description: Protocol for port. Must be UDP or TCP. Defaults
                            to "TCP".
                          type: string
                      required:
                      - containerPort
                    type: array
                  readinessProbe:
                    description: Probe describes a health check to be performed against
                      a container to determine whether it is alive or ready to receive
                      traffic.
                    properties:
                      exec:
                        description: ExecAction describes a "run in container" action.
                        properties:
                          command:
                            description: Command is the command line to execute inside
                              the container, the working directory for the command  is
                              root ('/') in the container's filesystem. The command
                              is simply exec'd, it is not run inside a shell, so traditional
                              shell instructions ('|', etc) won't work. To use a shell,
                              you need to explicitly call out to that shell. Exit
                              status of 0 is treated as live/healthy and non-zero
                              is unhealthy.
                            items:
                              type: string
                            type: array
                      failureThreshold:
                        description: Minimum consecutive failures for the probe to
                          be considered failed after having succeeded. Defaults to
                          3. Minimum value is 1.
                        format: int32
                        type: integer
                      httpGet:
                        description: HTTPGetAction describes an action based on HTTP
                          Get requests.
                        properties:
                          host:
                            description: Host name to connect to, defaults to the
                              pod IP. You probably want to set "Host" in httpHeaders
                              instead.
                            type: string
                          httpHeaders:
                            description: Custom headers to set in the request. HTTP
                              allows repeated headers.
                            items:
                              description: HTTPHeader describes a custom header to
                                be used in HTTP probes
                              properties:
                                name:
                                  description: The header field name
                                  type: string
                                value:
                                  description: The header field value
                                  type: string
                              required:
                              - name
                              - value
                            type: array
                          path:
                            description: Path to access on the HTTP server.
                            type: string
                          port: {}
                          scheme:
                            description: Scheme to use for connecting to the host.
                              Defaults to HTTP.
                            type: string
                        required:
                        - port
                      initialDelaySeconds:
                        description: 'Number of seconds after the container has started
                          before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                      periodSeconds:
                        description: How often (in seconds) to perform the probe.
                          Default to 10 seconds. Minimum value is 1.
                        format: int32
                        type: integer
                      successThreshold:
                        description: Minimum consecutive successes for the probe to
                          be considered successful after having failed. Defaults to
                          1. Must be 1 for liveness. Minimum value is 1.
                        format: int32
                        type: integer
                      tcpSocket:
                        description: TCPSocketAction describes an action based on
                          opening a socket
                        properties:
                          host:
                            description: 'Optional: Host name to connect to, defaults
                              to the pod IP.'
                            type: string
                          port: {}
                        required:
                        - port
                      timeoutSeconds:
                        description: 'Number of seconds after which the probe times
                          out. Defaults to 1 second. Minimum value is 1. More info:
                          https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes'
                        format: int32
                        type: integer
                  resources:
                    description: ResourceRequirements describes the compute resource
                      requirements.
                    properties:
                      limits:
                        description: 'Limits describes the maximum amount of compute
                          resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                        type: object
                      requests:
                        description: 'Requests describes the minimum amount of compute
                          resources required. If Requests is omitted for a container,
                          it defaults to Limits if that is explicitly specified, otherwise
                          to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                        type: object
                  securityContext:
                    description: SecurityContext holds security configuration that
                      will be applied to a container. Some fields are present in both
                      SecurityContext and PodSecurityContext.  When both are set,
                      the values in SecurityContext take precedence.
                    properties:
                      allowPrivilegeEscalation:
                        description: 'AllowPrivilegeEscalation controls whether a
                          process can gain more privileges than its parent process.
                          This bool directly controls if the no_new_privs flag will
                          be set on the container process. AllowPrivilegeEscalation
                          is true always when the container is: 1) run as Privileged
                          2) has CAP_SYS_ADMIN'
                        type: boolean
                      capabilities:
                        description: Adds and removes POSIX capabilities from running
                          containers.
                        properties:
                          add:
                            description: Added capabilities
                            items:
                              type: string
                            type: array
                          drop:
                            description: Removed capabilities
                            items:
                              type: string
                            type: array
                      privileged:
                        description: Run container in privileged mode. Processes in
                          privileged containers are essentially equivalent to root
                          on the host. Defaults to false.
                        type: boolean
                      readOnlyRootFilesystem:
                        description: Whether this container has a read-only root filesystem.
                          Default is false.
                        type: boolean
                      runAsNonRoot:
                        description: Indicates that the container must run as a non-root
                          user. If true, the Kubelet will validate the image at runtime
                          to ensure that it does not run as UID 0 (root) and fail
                          to start the container if it does. If unset or false, no
                          such validation will be performed. May also be set in PodSecurityContext.  If
                          set in both SecurityContext and PodSecurityContext, the
                          value specified in SecurityContext takes precedence.
                        type: boolean
                      runAsUser:
                        description: The UID to run the entrypoint of the container
                          process. Defaults to user specified in image metadata if
                          unspecified. May also be set in PodSecurityContext.  If
                          set in both SecurityContext and PodSecurityContext, the
                          value specified in SecurityContext takes precedence.
                        format: int64
                        type: integer
                      seLinuxOptions:
                        description: SELinuxOptions are the labels to be applied to
                          the container
                        properties:
                          level:
                            description: Level is SELinux level label that applies
                              to the container.
                            type: string
                          role:
                            description: Role is a SELinux role label that applies
                              to the container.
                            type: string
                          type:
                            description: Type is a SELinux type label that applies
                              to the container.
                            type: string
                          user:
                            description: User is a SELinux user label that applies
                              to the container.
                            type: string
                  stdin:
                    description: Whether this container should allocate a buffer for
                      stdin in the container runtime. If this is not set, reads from
                      stdin in the container will always result in EOF. Default is
                      false.
                    type: boolean
                  stdinOnce:
                    description: Whether the container runtime should close the stdin
                      channel after it has been opened by a single attach. When stdin
                      is true the stdin stream will remain open across multiple attach
                      sessions. If stdinOnce is set to true, stdin is opened on container
                      start, is empty until the first client attaches to stdin, and
                      then remains open and accepts data until the client disconnects,
                      at which time stdin is closed and remains closed until the container
                      is restarted. If this flag is false, a container processes that
                      reads from stdin will never receive an EOF. Default is false
                    type: boolean
                  terminationMessagePath:
                    description: 'Optional: Path at which the file to which the container''s
                      termination message will be written is mounted into the container''s
                      filesystem. Message written is intended to be brief final status,
                      such as an assertion failure message. Will be truncated by the
                      node if greater than 4096 bytes. The total message length across
                      all containers will be limited to 12kb. Defaults to /dev/termination-log.
                      Cannot be updated.'
                    type: string
                  terminationMessagePolicy:
                    description: Indicate how the termination message should be populated.
                      File will use the contents of terminationMessagePath to populate
                      the container status message on both success and failure. FallbackToLogsOnError
                      will use the last chunk of container log output if the termination
                      message file is empty and the container exited with an error.
                      The log output is limited to 2048 bytes or 80 lines, whichever
                      is smaller. Defaults to File. Cannot be updated.
                    type: string
                  tty:
                    description: Whether this container should allocate a TTY for
                      itself, also requires 'stdin' to be true. Default is false.
                    type: boolean
                  volumeDevices:
                    description: volumeDevices is the list of block devices to be
                      used by the container. This is an alpha feature and may change
                      in the future.
                    items:
                      description: volumeDevice describes a mapping of a raw block
                        device within a container.
                      properties:
                        devicePath:
                          description: devicePath is the path inside of the container
                            that the device will be mapped to.
                          type: string
                        name:
                          description: name must match the name of a persistentVolumeClaim
                            in the pod
                          type: string
                      required:
                      - name
                      - devicePath
                    type: array
                  volumeMounts:
                    description: Pod volumes to mount into the container's filesystem.
                      Cannot be updated.
                    items:
                      description: VolumeMount describes a mounting of a Volume within
                        a container.
                      properties:
                        mountPath:
                          description: Path within the container at which the volume
                            should be mounted.  Must not contain ':'.
                          type: string
                        mountPropagation:
                          description: mountPropagation determines how mounts are
                            propagated from the host to container and the other way
                            around. When not set, MountPropagationHostToContainer
                            is used. This field is alpha in 1.8 and can be reworked
                            or removed in a future release.
                          type: string
                        name:
                          description: This must match the Name of a Volume.
                          type: string
                        readOnly:
                          description: Mounted read-only if true, read-write otherwise
                            (false or unspecified). Defaults to false.
                          type: boolean
                        subPath:
                          description: Path within the volume from which the container's
                            volume should be mounted. Defaults to "" (volume's root).
                          type: string
                      required:
                      - name
                      - mountPath
                    type: array
                  workingDir:
                    description: Container's working directory. If not specified,
                      the container runtime's default will be used, which might be
                      configured in the container image. Cannot be updated.
                    type: string
                required:
                - name
              type: array
            evaluationInterval:
              description: Interval between consecutive evaluations.
              type: string
            externalLabels:
              description: The labels to add to any time series or alerts when communicating
                with external systems (federation, remote storage, Alertmanager).
              type: object
            externalUrl:
              description: The external URL the Prometheus instances will be available
                under. This is necessary to generate correct URLs. This is necessary
                if Prometheus is not served from root of a DNS name.
              type: string
            imagePullSecrets:
              description: An optional list of references to secrets in the same namespace
                to use for pulling prometheus and alertmanager images from registries
                see http://kubernetes.io/docs/user-guide/images#specifying-imagepullsecrets-on-a-pod
              items:
                description: LocalObjectReference contains enough information to let
                  you locate the referenced object inside the same namespace.
                properties:
                  name:
                    description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                    type: string
              type: array
            listenLocal:
              description: ListenLocal makes the Prometheus server listen on loopback,
                so that it does not bind against the Pod IP.
              type: boolean
            logLevel:
              description: Log level for Prometheus to be configured with.
              type: string
            nodeSelector:
              description: Define which Nodes the Pods are scheduled on.
              type: object
            paused:
              description: When a Prometheus deployment is paused, no actions except
                for deletion will be performed on the underlying objects.
              type: boolean
            podMetadata:
              description: ObjectMeta is metadata that all persisted resources must
                have, which includes all objects users must create.
              properties:
                annotations:
                  description: 'Annotations is an unstructured key value map stored
                    with a resource that may be set by external tools to store and
                    retrieve arbitrary metadata. They are not queryable and should
                    be preserved when modifying objects. More info: http://kubernetes.io/docs/user-guide/annotations'
                  type: object
                clusterName:
                  description: The name of the cluster which the object belongs to.
                    This is used to distinguish resources with same name and namespace
                    in different clusters. This field is not set anywhere right now
                    and apiserver is going to ignore it if set in create or update
                    request.
                  type: string
                creationTimestamp:
                  format: date-time
                  type: string
                deletionGracePeriodSeconds:
                  description: Number of seconds allowed for this object to gracefully
                    terminate before it will be removed from the system. Only set
                    when deletionTimestamp is also set. May only be shortened. Read-only.
                  format: int64
                  type: integer
                deletionTimestamp:
                  format: date-time
                  type: string
                finalizers:
                  description: Must be empty before the object is deleted from the
                    registry. Each entry is an identifier for the responsible component
                    that will remove the entry from the list. If the deletionTimestamp
                    of the object is non-nil, entries in this list can only be removed.
                  items:
                    type: string
                  type: array
                generateName:
                  description: |-
                    GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.

                    If this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).

                    Applied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#idempotency
                  type: string
                generation:
                  description: A sequence number representing a specific generation
                    of the desired state. Populated by the system. Read-only.
                  format: int64
                  type: integer
                initializers:
                  description: Initializers tracks the progress of initialization.
                  properties:
                    pending:
                      description: Pending is a list of initializers that must execute
                        in order before this object is visible. When the last pending
                        initializer is removed, and no failing result is set, the
                        initializers struct will be set to nil and the object is considered
                        as initialized and visible to all clients.
                      items:
                        description: Initializer is information about an initializer
                          that has not yet completed.
                        properties:
                          name:
                            description: name of the process that is responsible for
                              initializing this object.
                            type: string
                        required:
                        - name
                      type: array
                    result:
                      description: Status is a return value for calls that don't return
                        other objects.
                      properties:
                        apiVersion:
                          description: 'APIVersion defines the versioned schema of
                            this representation of an object. Servers should convert
                            recognized schemas to the latest internal value, and may
                            reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                          type: string
                        code:
                          description: Suggested HTTP return code for this status,
                            0 if not set.
                          format: int32
                          type: integer
                        details:
                          description: StatusDetails is a set of additional properties
                            that MAY be set by the server to provide additional information
                            about a response. The Reason field of a Status object
                            defines what attributes will be set. Clients must ignore
                            fields that do not match the defined type of each attribute,
                            and should assume that any attribute may be empty, invalid,
                            or under defined.
                          properties:
                            causes:
                              description: The Causes array includes more details
                                associated with the StatusReason failure. Not all
                                StatusReasons may provide detailed causes.
                              items:
                                description: StatusCause provides more information
                                  about an api.Status failure, including cases when
                                  multiple errors are encountered.
                                properties:
                                  field:
                                    description: |-
                                      The field of the resource that has caused this error, as named by its JSON serialization. May include dot and postfix notation for nested attributes. Arrays are zero-indexed.  Fields may appear more than once in an array of causes due to fields having multiple errors. Optional.

                                      Examples:
                                        "name" - the field "name" on the current resource
                                        "items[0].name" - the field "name" on the first array entry in "items"
                                    type: string
                                  message:
                                    description: A human-readable description of the
                                      cause of the error.  This field may be presented
                                      as-is to a reader.
                                    type: string
                                  reason:
                                    description: A machine-readable description of
                                      the cause of the error. If this value is empty
                                      there is no information available.
                                    type: string
                              type: array
                            group:
                              description: The group attribute of the resource associated
                                with the status StatusReason.
                              type: string
                            kind:
                              description: 'The kind attribute of the resource associated
                                with the status StatusReason. On some operations may
                                differ from the requested resource Kind. More info:
                                https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                              type: string
                            name:
                              description: The name attribute of the resource associated
                                with the status StatusReason (when there is a single
                                name which can be described).
                              type: string
                            retryAfterSeconds:
                              description: If specified, the time in seconds before
                                the operation should be retried. Some errors may indicate
                                the client must take an alternate action - for those
                                errors this field may indicate how long to wait before
                                taking the alternate action.
                              format: int32
                              type: integer
                            uid:
                              description: 'UID of the resource. (when there is a
                                single resource which can be described). More info:
                                http://kubernetes.io/docs/user-guide/identifiers#uids'
                              type: string
                        kind:
                          description: 'Kind is a string value representing the REST
                            resource this object represents. Servers may infer this
                            from the endpoint the client submits requests to. Cannot
                            be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                          type: string
                        message:
                          description: A human-readable description of the status
                            of this operation.
                          type: string
                        metadata:
                          description: ListMeta describes metadata that synthetic
                            resources must have, including lists and various status
                            objects. A resource may have only one of {ObjectMeta,
                            ListMeta}.
                          properties:
                            continue:
                              description: continue may be set if the user set a limit
                                on the number of items returned, and indicates that
                                the server has more data available. The value is opaque
                                and may be used to issue another request to the endpoint
                                that served this list to retrieve the next set of
                                available objects. Continuing a list may not be possible
                                if the server configuration has changed or more than
                                a few minutes have passed. The resourceVersion field
                                returned when using this continue value will be identical
                                to the value in the first response.
                              type: string
                            resourceVersion:
                              description: 'String that identifies the server''s internal
                                version of this object that can be used by clients
                                to determine when objects have changed. Value must
                                be treated as opaque by clients and passed unmodified
                                back to the server. Populated by the system. Read-only.
                                More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency'
                              type: string
                            selfLink:
                              description: selfLink is a URL representing this object.
                                Populated by the system. Read-only.
                              type: string
                        reason:
                          description: A machine-readable description of why this
                            operation is in the "Failure" status. If this value is
                            empty there is no information available. A Reason clarifies
                            an HTTP status code but does not override it.
                          type: string
                        status:
                          description: 'Status of the operation. One of: "Success"
                            or "Failure". More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status'
                          type: string
                  required:
                  - pending
                labels:
                  description: 'Map of string keys and values that can be used to
                    organize and categorize (scope and select) objects. May match
                    selectors of replication controllers and services. More info:
                    http://kubernetes.io/docs/user-guide/labels'
                  type: object
                name:
                  description: 'Name must be unique within a namespace. Is required
                    when creating resources, although some resources may allow a client
                    to request the generation of an appropriate name automatically.
                    Name is primarily intended for creation idempotence and configuration
                    definition. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                  type: string
                namespace:
                  description: |-
                    Namespace defines the space within each name must be unique. An empty namespace is equivalent to the "default" namespace, but "default" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.

                    Must be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces
                  type: string
                ownerReferences:
                  description: List of objects depended by this object. If ALL objects
                    in the list have been deleted, this object will be garbage collected.
                    If this object is managed by a controller, then an entry in this
                    list will point to this controller, with the controller field
                    set to true. There cannot be more than one managing controller.
                  items:
                    description: OwnerReference contains enough information to let
                      you identify an owning object. Currently, an owning object must
                      be in the same namespace, so there is no namespace field.
                    properties:
                      apiVersion:
                        description: API version of the referent.
                        type: string
                      blockOwnerDeletion:
                        description: If true, AND if the owner has the "foregroundDeletion"
                          finalizer, then the owner cannot be deleted from the key-value
                          store until this reference is removed. Defaults to false.
                          To set this field, a user needs "delete" permission of the
                          owner, otherwise 422 (Unprocessable Entity) will be returned.
                        type: boolean
                      controller:
                        description: If true, this reference points to the managing
                          controller.
                        type: boolean
                      kind:
                        description: 'Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                        type: string
                      name:
                        description: 'Name of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                        type: string
                      uid:
                        description: 'UID of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                        type: string
                    required:
                    - apiVersion
                    - kind
                    - name
                    - uid
                  type: array
                resourceVersion:
                  description: |-
                    An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.

                    Populated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency
                  type: string
                selfLink:
                  description: SelfLink is a URL representing this object. Populated
                    by the system. Read-only.
                  type: string
                uid:
                  description: |-
                    UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.

                    Populated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids
                  type: string
            remoteRead:
              description: If specified, the remote_read spec. This is an experimental
                feature, it may change in any upcoming release in a breaking way.
              items:
                description: RemoteReadSpec defines the remote_read configuration
                  for prometheus.
                properties:
                  basicAuth:
                    description: 'BasicAuth allow an endpoint to authenticate over
                      basic authentication More info: https://prometheus.io/docs/operating/configuration/#endpoints'
                    properties:
                      password:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                      username:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                  bearerToken:
                    description: bearer token for remote read.
                    type: string
                  bearerTokenFile:
                    description: File to read bearer token for remote read.
                    type: string
                  proxyUrl:
                    description: Optional ProxyURL
                    type: string
                  readRecent:
                    description: Whether reads should be made for queries for time
                      ranges that the local storage should have complete data for.
                    type: boolean
                  remoteTimeout:
                    description: Timeout for requests to the remote read endpoint.
                    type: string
                  requiredMatchers:
                    description: An optional list of equality matchers which have
                      to be present in a selector to query the remote read endpoint.
                    type: object
                  tlsConfig:
                    description: TLSConfig specifies TLS configuration parameters.
                    properties:
                      caFile:
                        description: The CA cert to use for the targets.
                        type: string
                      certFile:
                        description: The client cert file for the targets.
                        type: string
                      insecureSkipVerify:
                        description: Disable target certificate validation.
                        type: boolean
                      keyFile:
                        description: The client key file for the targets.
                        type: string
                      serverName:
                        description: Used to verify the hostname for the targets.
                        type: string
                  url:
                    description: The URL of the endpoint to send samples to.
                    type: string
                required:
                - url
              type: array
            remoteWrite:
              description: If specified, the remote_write spec. This is an experimental
                feature, it may change in any upcoming release in a breaking way.
              items:
                description: RemoteWriteSpec defines the remote_write configuration
                  for prometheus.
                properties:
                  basicAuth:
                    description: 'BasicAuth allow an endpoint to authenticate over
                      basic authentication More info: https://prometheus.io/docs/operating/configuration/#endpoints'
                    properties:
                      password:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                      username:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                  bearerToken:
                    description: File to read bearer token for remote write.
                    type: string
                  bearerTokenFile:
                    description: File to read bearer token for remote write.
                    type: string
                  proxyUrl:
                    description: Optional ProxyURL
                    type: string
                  remoteTimeout:
                    description: Timeout for requests to the remote write endpoint.
                    type: string
                  tlsConfig:
                    description: TLSConfig specifies TLS configuration parameters.
                    properties:
                      caFile:
                        description: The CA cert to use for the targets.
                        type: string
                      certFile:
                        description: The client cert file for the targets.
                        type: string
                      insecureSkipVerify:
                        description: Disable target certificate validation.
                        type: boolean
                      keyFile:
                        description: The client key file for the targets.
                        type: string
                      serverName:
                        description: Used to verify the hostname for the targets.
                        type: string
                  url:
                    description: The URL of the endpoint to send samples to.
                    type: string
                  writeRelabelConfigs:
                    description: The list of remote write relabel configurations.
                    items:
                      description: 'RelabelConfig allows dynamic rewriting of the
                        label set, being applied to samples before ingestion. It defines
                        `<metric_relabel_configs>`-section of Prometheus configuration.
                        More info: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs'
                      properties:
                        action:
                          description: Action to perform based on regex matching.
                            Default is 'replace'
                          type: string
                        modulus:
                          description: Modulus to take of the hash of the source label
                            values.
                          format: int64
                          type: integer
                        regex:
                          description: Regular expression against which the extracted
                            value is matched. defailt is '(.*)'
                          type: string
                        replacement:
                          description: Replacement value against which a regex replace
                            is performed if the regular expression matches. Regex
                            capture groups are available. Default is '$1'
                          type: string
                        separator:
                          description: Separator placed between concatenated source
                            label values. default is ';'.
                          type: string
                        sourceLabels:
                          description: The source labels select values from existing
                            labels. Their content is concatenated using the configured
                            separator and matched against the configured regular expression
                            for the replace, keep, and drop actions.
                          items:
                            type: string
                          type: array
                        targetLabel:
                          description: Label to which the resulting value is written
                            in a replace action. It is mandatory for replace actions.
                            Regex capture groups are available.
                          type: string
                    type: array
                required:
                - url
              type: array
            replicas:
              description: Number of instances to deploy for a Prometheus deployment.
              format: int32
              type: integer
            resources:
              description: ResourceRequirements describes the compute resource requirements.
              properties:
                limits:
                  description: 'Limits describes the maximum amount of compute resources
                    allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                  type: object
                requests:
                  description: 'Requests describes the minimum amount of compute resources
                    required. If Requests is omitted for a container, it defaults
                    to Limits if that is explicitly specified, otherwise to an implementation-defined
                    value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                  type: object
            retention:
              description: Time duration Prometheus shall retain data for.
              type: string
            routePrefix:
              description: The route prefix Prometheus registers HTTP handlers for.
                This is useful, if using ExternalURL and a proxy is rewriting HTTP
                routes of a request, and the actual ExternalURL is still true, but
                the server serves requests under a different route prefix. For example
                for use with `kubectl proxy`.
              type: string
            ruleSelector:
              description: A label selector is a label query over a set of resources.
                The result of matchLabels and matchExpressions are ANDed. An empty
                label selector matches all objects. A null label selector matches
                no objects.
              properties:
                matchExpressions:
                  description: matchExpressions is a list of label selector requirements.
                    The requirements are ANDed.
                  items:
                    description: A label selector requirement is a selector that contains
                      values, a key, and an operator that relates the key and values.
                    properties:
                      key:
                        description: key is the label key that the selector applies
                          to.
                        type: string
                      operator:
                        description: operator represents a key's relationship to a
                          set of values. Valid operators are In, NotIn, Exists and
                          DoesNotExist.
                        type: string
                      values:
                        description: values is an array of string values. If the operator
                          is In or NotIn, the values array must be non-empty. If the
                          operator is Exists or DoesNotExist, the values array must
                          be empty. This array is replaced during a strategic merge
                          patch.
                        items:
                          type: string
                        type: array
                    required:
                    - key
                    - operator
                  type: array
                matchLabels:
                  description: matchLabels is a map of {key,value} pairs. A single
                    {key,value} in the matchLabels map is equivalent to an element
                    of matchExpressions, whose key field is "key", the operator is
                    "In", and the values array contains only "value". The requirements
                    are ANDed.
                  type: object
            scrapeInterval:
              description: Interval between consecutive scrapes.
              type: string
            secrets:
              description: Secrets is a list of Secrets in the same namespace as the
                Prometheus object, which shall be mounted into the Prometheus Pods.
                The Secrets are mounted into /etc/prometheus/secrets/<secret-name>.
                Secrets changes after initial creation of a Prometheus object are
                not reflected in the running Pods. To change the secrets mounted into
                the Prometheus Pods, the object must be deleted and recreated with
                the new list of secrets.
              items:
                type: string
              type: array
            securityContext:
              description: PodSecurityContext holds pod-level security attributes
                and common container settings. Some fields are also present in container.securityContext.  Field
                values of container.securityContext take precedence over field values
                of PodSecurityContext.
              properties:
                fsGroup:
                  description: |-
                    A special supplemental group that applies to all containers in a pod. Some volume types allow the Kubelet to change the ownership of that volume to be owned by the pod:

                    1. The owning GID will be the FSGroup 2. The setgid bit is set (new files created in the volume will be owned by FSGroup) 3. The permission bits are OR'd with rw-rw----

                    If unset, the Kubelet will not modify the ownership and permissions of any volume.
                  format: int64
                  type: integer
                runAsNonRoot:
                  description: Indicates that the container must run as a non-root
                    user. If true, the Kubelet will validate the image at runtime
                    to ensure that it does not run as UID 0 (root) and fail to start
                    the container if it does. If unset or false, no such validation
                    will be performed. May also be set in SecurityContext.  If set
                    in both SecurityContext and PodSecurityContext, the value specified
                    in SecurityContext takes precedence.
                  type: boolean
                runAsUser:
                  description: The UID to run the entrypoint of the container process.
                    Defaults to user specified in image metadata if unspecified. May
                    also be set in SecurityContext.  If set in both SecurityContext
                    and PodSecurityContext, the value specified in SecurityContext
                    takes precedence for that container.
                  format: int64
                  type: integer
                seLinuxOptions:
                  description: SELinuxOptions are the labels to be applied to the
                    container
                  properties:
                    level:
                      description: Level is SELinux level label that applies to the
                        container.
                      type: string
                    role:
                      description: Role is a SELinux role label that applies to the
                        container.
                      type: string
                    type:
                      description: Type is a SELinux type label that applies to the
                        container.
                      type: string
                    user:
                      description: User is a SELinux user label that applies to the
                        container.
                      type: string
                supplementalGroups:
                  description: A list of groups applied to the first process run in
                    each container, in addition to the container's primary GID.  If
                    unspecified, no groups will be added to any container.
                  items:
                    format: int64
                    type: integer
                  type: array
            serviceAccountName:
              description: ServiceAccountName is the name of the ServiceAccount to
                use to run the Prometheus Pods.
              type: string
            serviceMonitorNamespaceSelector:
              description: A label selector is a label query over a set of resources.
                The result of matchLabels and matchExpressions are ANDed. An empty
                label selector matches all objects. A null label selector matches
                no objects.
              properties:
                matchExpressions:
                  description: matchExpressions is a list of label selector requirements.
                    The requirements are ANDed.
                  items:
                    description: A label selector requirement is a selector that contains
                      values, a key, and an operator that relates the key and values.
                    properties:
                      key:
                        description: key is the label key that the selector applies
                          to.
                        type: string
                      operator:
                        description: operator represents a key's relationship to a
                          set of values. Valid operators are In, NotIn, Exists and
                          DoesNotExist.
                        type: string
                      values:
                        description: values is an array of string values. If the operator
                          is In or NotIn, the values array must be non-empty. If the
                          operator is Exists or DoesNotExist, the values array must
                          be empty. This array is replaced during a strategic merge
                          patch.
                        items:
                          type: string
                        type: array
                    required:
                    - key
                    - operator
                  type: array
                matchLabels:
                  description: matchLabels is a map of {key,value} pairs. A single
                    {key,value} in the matchLabels map is equivalent to an element
                    of matchExpressions, whose key field is "key", the operator is
                    "In", and the values array contains only "value". The requirements
                    are ANDed.
                  type: object
            serviceMonitorSelector:
              description: A label selector is a label query over a set of resources.
                The result of matchLabels and matchExpressions are ANDed. An empty
                label selector matches all objects. A null label selector matches
                no objects.
              properties:
                matchExpressions:
                  description: matchExpressions is a list of label selector requirements.
                    The requirements are ANDed.
                  items:
                    description: A label selector requirement is a selector that contains
                      values, a key, and an operator that relates the key and values.
                    properties:
                      key:
                        description: key is the label key that the selector applies
                          to.
                        type: string
                      operator:
                        description: operator represents a key's relationship to a
                          set of values. Valid operators are In, NotIn, Exists and
                          DoesNotExist.
                        type: string
                      values:
                        description: values is an array of string values. If the operator
                          is In or NotIn, the values array must be non-empty. If the
                          operator is Exists or DoesNotExist, the values array must
                          be empty. This array is replaced during a strategic merge
                          patch.
                        items:
                          type: string
                        type: array
                    required:
                    - key
                    - operator
                  type: array
                matchLabels:
                  description: matchLabels is a map of {key,value} pairs. A single
                    {key,value} in the matchLabels map is equivalent to an element
                    of matchExpressions, whose key field is "key", the operator is
                    "In", and the values array contains only "value". The requirements
                    are ANDed.
                  type: object
            storage:
              description: StorageSpec defines the configured storage for a group
                Prometheus servers.
              properties:
                class:
                  description: 'Name of the StorageClass to use when requesting storage
                    provisioning. More info: https://kubernetes.io/docs/user-guide/persistent-volumes/#storageclasses
                    DEPRECATED'
                  type: string
                emptyDir:
                  description: Represents an empty directory for a pod. Empty directory
                    volumes support ownership management and SELinux relabeling.
                  properties:
                    medium:
                      description: 'What type of storage medium should back this directory.
                        The default is "" which means to use the node''s default medium.
                        Must be an empty string (default) or Memory. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir'
                      type: string
                    sizeLimit: {}
                resources:
                  description: ResourceRequirements describes the compute resource
                    requirements.
                  properties:
                    limits:
                      description: 'Limits describes the maximum amount of compute
                        resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                      type: object
                    requests:
                      description: 'Requests describes the minimum amount of compute
                        resources required. If Requests is omitted for a container,
                        it defaults to Limits if that is explicitly specified, otherwise
                        to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                      type: object
                selector:
                  description: A label selector is a label query over a set of resources.
                    The result of matchLabels and matchExpressions are ANDed. An empty
                    label selector matches all objects. A null label selector matches
                    no objects.
                  properties:
                    matchExpressions:
                      description: matchExpressions is a list of label selector requirements.
                        The requirements are ANDed.
                      items:
                        description: A label selector requirement is a selector that
                          contains values, a key, and an operator that relates the
                          key and values.
                        properties:
                          key:
                            description: key is the label key that the selector applies
                              to.
                            type: string
                          operator:
                            description: operator represents a key's relationship
                              to a set of values. Valid operators are In, NotIn, Exists
                              and DoesNotExist.
                            type: string
                          values:
                            description: values is an array of string values. If the
                              operator is In or NotIn, the values array must be non-empty.
                              If the operator is Exists or DoesNotExist, the values
                              array must be empty. This array is replaced during a
                              strategic merge patch.
                            items:
                              type: string
                            type: array
                        required:
                        - key
                        - operator
                      type: array
                    matchLabels:
                      description: matchLabels is a map of {key,value} pairs. A single
                        {key,value} in the matchLabels map is equivalent to an element
                        of matchExpressions, whose key field is "key", the operator
                        is "In", and the values array contains only "value". The requirements
                        are ANDed.
                      type: object
                volumeClaimTemplate:
                  description: PersistentVolumeClaim is a user's request for and claim
                    to a persistent volume
                  properties:
                    apiVersion:
                      description: 'APIVersion defines the versioned schema of this
                        representation of an object. Servers should convert recognized
                        schemas to the latest internal value, and may reject unrecognized
                        values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                      type: string
                    kind:
                      description: 'Kind is a string value representing the REST resource
                        this object represents. Servers may infer this from the endpoint
                        the client submits requests to. Cannot be updated. In CamelCase.
                        More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                      type: string
                    metadata:
                      description: ObjectMeta is metadata that all persisted resources
                        must have, which includes all objects users must create.
                      properties:
                        annotations:
                          description: 'Annotations is an unstructured key value map
                            stored with a resource that may be set by external tools
                            to store and retrieve arbitrary metadata. They are not
                            queryable and should be preserved when modifying objects.
                            More info: http://kubernetes.io/docs/user-guide/annotations'
                          type: object
                        clusterName:
                          description: The name of the cluster which the object belongs
                            to. This is used to distinguish resources with same name
                            and namespace in different clusters. This field is not
                            set anywhere right now and apiserver is going to ignore
                            it if set in create or update request.
                          type: string
                        creationTimestamp:
                          format: date-time
                          type: string
                        deletionGracePeriodSeconds:
                          description: Number of seconds allowed for this object to
                            gracefully terminate before it will be removed from the
                            system. Only set when deletionTimestamp is also set. May
                            only be shortened. Read-only.
                          format: int64
                          type: integer
                        deletionTimestamp:
                          format: date-time
                          type: string
                        finalizers:
                          description: Must be empty before the object is deleted
                            from the registry. Each entry is an identifier for the
                            responsible component that will remove the entry from
                            the list. If the deletionTimestamp of the object is non-nil,
                            entries in this list can only be removed.
                          items:
                            type: string
                          type: array
                        generateName:
                          description: |-
                            GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.

                            If this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).

                            Applied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#idempotency
                          type: string
                        generation:
                          description: A sequence number representing a specific generation
                            of the desired state. Populated by the system. Read-only.
                          format: int64
                          type: integer
                        initializers:
                          description: Initializers tracks the progress of initialization.
                          properties:
                            pending:
                              description: Pending is a list of initializers that
                                must execute in order before this object is visible.
                                When the last pending initializer is removed, and
                                no failing result is set, the initializers struct
                                will be set to nil and the object is considered as
                                initialized and visible to all clients.
                              items:
                                description: Initializer is information about an initializer
                                  that has not yet completed.
                                properties:
                                  name:
                                    description: name of the process that is responsible
                                      for initializing this object.
                                    type: string
                                required:
                                - name
                              type: array
                            result:
                              description: Status is a return value for calls that
                                don't return other objects.
                              properties:
                                apiVersion:
                                  description: 'APIVersion defines the versioned schema
                                    of this representation of an object. Servers should
                                    convert recognized schemas to the latest internal
                                    value, and may reject unrecognized values. More
                                    info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
                                  type: string
                                code:
                                  description: Suggested HTTP return code for this
                                    status, 0 if not set.
                                  format: int32
                                  type: integer
                                details:
                                  description: StatusDetails is a set of additional
                                    properties that MAY be set by the server to provide
                                    additional information about a response. The Reason
                                    field of a Status object defines what attributes
                                    will be set. Clients must ignore fields that do
                                    not match the defined type of each attribute,
                                    and should assume that any attribute may be empty,
                                    invalid, or under defined.
                                  properties:
                                    causes:
                                      description: The Causes array includes more
                                        details associated with the StatusReason failure.
                                        Not all StatusReasons may provide detailed
                                        causes.
                                      items:
                                        description: StatusCause provides more information
                                          about an api.Status failure, including cases
                                          when multiple errors are encountered.
                                        properties:
                                          field:
                                            description: |-
                                              The field of the resource that has caused this error, as named by its JSON serialization. May include dot and postfix notation for nested attributes. Arrays are zero-indexed.  Fields may appear more than once in an array of causes due to fields having multiple errors. Optional.

                                              Examples:
                                                "name" - the field "name" on the current resource
                                                "items[0].name" - the field "name" on the first array entry in "items"
                                            type: string
                                          message:
                                            description: A human-readable description
                                              of the cause of the error.  This field
                                              may be presented as-is to a reader.
                                            type: string
                                          reason:
                                            description: A machine-readable description
                                              of the cause of the error. If this value
                                              is empty there is no information available.
                                            type: string
                                      type: array
                                    group:
                                      description: The group attribute of the resource
                                        associated with the status StatusReason.
                                      type: string
                                    kind:
                                      description: 'The kind attribute of the resource
                                        associated with the status StatusReason. On
                                        some operations may differ from the requested
                                        resource Kind. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                      type: string
                                    name:
                                      description: The name attribute of the resource
                                        associated with the status StatusReason (when
                                        there is a single name which can be described).
                                      type: string
                                    retryAfterSeconds:
                                      description: If specified, the time in seconds
                                        before the operation should be retried. Some
                                        errors may indicate the client must take an
                                        alternate action - for those errors this field
                                        may indicate how long to wait before taking
                                        the alternate action.
                                      format: int32
                                      type: integer
                                    uid:
                                      description: 'UID of the resource. (when there
                                        is a single resource which can be described).
                                        More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                                      type: string
                                kind:
                                  description: 'Kind is a string value representing
                                    the REST resource this object represents. Servers
                                    may infer this from the endpoint the client submits
                                    requests to. Cannot be updated. In CamelCase.
                                    More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                  type: string
                                message:
                                  description: A human-readable description of the
                                    status of this operation.
                                  type: string
                                metadata:
                                  description: ListMeta describes metadata that synthetic
                                    resources must have, including lists and various
                                    status objects. A resource may have only one of
                                    {ObjectMeta, ListMeta}.
                                  properties:
                                    continue:
                                      description: continue may be set if the user
                                        set a limit on the number of items returned,
                                        and indicates that the server has more data
                                        available. The value is opaque and may be
                                        used to issue another request to the endpoint
                                        that served this list to retrieve the next
                                        set of available objects. Continuing a list
                                        may not be possible if the server configuration
                                        has changed or more than a few minutes have
                                        passed. The resourceVersion field returned
                                        when using this continue value will be identical
                                        to the value in the first response.
                                      type: string
                                    resourceVersion:
                                      description: 'String that identifies the server''s
                                        internal version of this object that can be
                                        used by clients to determine when objects
                                        have changed. Value must be treated as opaque
                                        by clients and passed unmodified back to the
                                        server. Populated by the system. Read-only.
                                        More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency'
                                      type: string
                                    selfLink:
                                      description: selfLink is a URL representing
                                        this object. Populated by the system. Read-only.
                                      type: string
                                reason:
                                  description: A machine-readable description of why
                                    this operation is in the "Failure" status. If
                                    this value is empty there is no information available.
                                    A Reason clarifies an HTTP status code but does
                                    not override it.
                                  type: string
                                status:
                                  description: 'Status of the operation. One of: "Success"
                                    or "Failure". More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status'
                                  type: string
                          required:
                          - pending
                        labels:
                          description: 'Map of string keys and values that can be
                            used to organize and categorize (scope and select) objects.
                            May match selectors of replication controllers and services.
                            More info: http://kubernetes.io/docs/user-guide/labels'
                          type: object
                        name:
                          description: 'Name must be unique within a namespace. Is
                            required when creating resources, although some resources
                            may allow a client to request the generation of an appropriate
                            name automatically. Name is primarily intended for creation
                            idempotence and configuration definition. Cannot be updated.
                            More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                          type: string
                        namespace:
                          description: |-
                            Namespace defines the space within each name must be unique. An empty namespace is equivalent to the "default" namespace, but "default" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.

                            Must be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces
                          type: string
                        ownerReferences:
                          description: List of objects depended by this object. If
                            ALL objects in the list have been deleted, this object
                            will be garbage collected. If this object is managed by
                            a controller, then an entry in this list will point to
                            this controller, with the controller field set to true.
                            There cannot be more than one managing controller.
                          items:
                            description: OwnerReference contains enough information
                              to let you identify an owning object. Currently, an
                              owning object must be in the same namespace, so there
                              is no namespace field.
                            properties:
                              apiVersion:
                                description: API version of the referent.
                                type: string
                              blockOwnerDeletion:
                                description: If true, AND if the owner has the "foregroundDeletion"
                                  finalizer, then the owner cannot be deleted from
                                  the key-value store until this reference is removed.
                                  Defaults to false. To set this field, a user needs
                                  "delete" permission of the owner, otherwise 422
                                  (Unprocessable Entity) will be returned.
                                type: boolean
                              controller:
                                description: If true, this reference points to the
                                  managing controller.
                                type: boolean
                              kind:
                                description: 'Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
                                type: string
                              name:
                                description: 'Name of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#names'
                                type: string
                              uid:
                                description: 'UID of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#uids'
                                type: string
                            required:
                            - apiVersion
                            - kind
                            - name
                            - uid
                          type: array
                        resourceVersion:
                          description: |-
                            An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.

                            Populated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency
                          type: string
                        selfLink:
                          description: SelfLink is a URL representing this object.
                            Populated by the system. Read-only.
                          type: string
                        uid:
                          description: |-
                            UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.

                            Populated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids
                          type: string
                    spec:
                      description: PersistentVolumeClaimSpec describes the common
                        attributes of storage devices and allows a Source for provider-specific
                        attributes
                      properties:
                        accessModes:
                          description: 'AccessModes contains the desired access modes
                            the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1'
                          items:
                            type: string
                          type: array
                        resources:
                          description: ResourceRequirements describes the compute
                            resource requirements.
                          properties:
                            limits:
                              description: 'Limits describes the maximum amount of
                                compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                              type: object
                            requests:
                              description: 'Requests describes the minimum amount
                                of compute resources required. If Requests is omitted
                                for a container, it defaults to Limits if that is
                                explicitly specified, otherwise to an implementation-defined
                                value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/'
                              type: object
                        selector:
                          description: A label selector is a label query over a set
                            of resources. The result of matchLabels and matchExpressions
                            are ANDed. An empty label selector matches all objects.
                            A null label selector matches no objects.
                          properties:
                            matchExpressions:
                              description: matchExpressions is a list of label selector
                                requirements. The requirements are ANDed.
                              items:
                                description: A label selector requirement is a selector
                                  that contains values, a key, and an operator that
                                  relates the key and values.
                                properties:
                                  key:
                                    description: key is the label key that the selector
                                      applies to.
                                    type: string
                                  operator:
                                    description: operator represents a key's relationship
                                      to a set of values. Valid operators are In,
                                      NotIn, Exists and DoesNotExist.
                                    type: string
                                  values:
                                    description: values is an array of string values.
                                      If the operator is In or NotIn, the values array
                                      must be non-empty. If the operator is Exists
                                      or DoesNotExist, the values array must be empty.
                                      This array is replaced during a strategic merge
                                      patch.
                                    items:
                                      type: string
                                    type: array
                                required:
                                - key
                                - operator
                              type: array
                            matchLabels:
                              description: matchLabels is a map of {key,value} pairs.
                                A single {key,value} in the matchLabels map is equivalent
                                to an element of matchExpressions, whose key field
                                is "key", the operator is "In", and the values array
                                contains only "value". The requirements are ANDed.
                              type: object
                        storageClassName:
                          description: 'Name of the StorageClass required by the claim.
                            More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1'
                          type: string
                        volumeMode:
                          description: volumeMode defines what type of volume is required
                            by the claim. Value of Filesystem is implied when not
                            included in claim spec. This is an alpha feature and may
                            change in the future.
                          type: string
                        volumeName:
                          description: VolumeName is the binding reference to the
                            PersistentVolume backing this claim.
                          type: string
                    status:
                      description: PersistentVolumeClaimStatus is the current status
                        of a persistent volume claim.
                      properties:
                        accessModes:
                          description: 'AccessModes contains the actual access modes
                            the volume backing the PVC has. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1'
                          items:
                            type: string
                          type: array
                        capacity:
                          description: Represents the actual resources of the underlying
                            volume.
                          type: object
                        conditions:
                          description: Current Condition of persistent volume claim.
                            If underlying persistent volume is being resized then
                            the Condition will be set to 'ResizeStarted'.
                          items:
                            description: PersistentVolumeClaimCondition contails details
                              about state of pvc
                            properties:
                              lastProbeTime:
                                format: date-time
                                type: string
                              lastTransitionTime:
                                format: date-time
                                type: string
                              message:
                                description: Human-readable message indicating details
                                  about last transition.
                                type: string
                              reason:
                                description: Unique, this should be a short, machine
                                  understandable string that gives the reason for
                                  condition's last transition. If it reports "ResizeStarted"
                                  that means the underlying persistent volume is being
                                  resized.
                                type: string
                              status:
                                type: string
                              type:
                                type: string
                            required:
                            - type
                            - status
                          type: array
                        phase:
                          description: Phase represents the current phase of PersistentVolumeClaim.
                          type: string
            tolerations:
              description: If specified, the pod's tolerations.
              items:
                description: The pod this Toleration is attached to tolerates any
                  taint that matches the triple <key,value,effect> using the matching
                  operator <operator>.
                properties:
                  effect:
                    description: Effect indicates the taint effect to match. Empty
                      means match all taint effects. When specified, allowed values
                      are NoSchedule, PreferNoSchedule and NoExecute.
                    type: string
                  key:
                    description: Key is the taint key that the toleration applies
                      to. Empty means match all taint keys. If the key is empty, operator
                      must be Exists; this combination means to match all values and
                      all keys.
                    type: string
                  operator:
                    description: Operator represents a key's relationship to the value.
                      Valid operators are Exists and Equal. Defaults to Equal. Exists
                      is equivalent to wildcard for value, so that a pod can tolerate
                      all taints of a particular category.
                    type: string
                  tolerationSeconds:
                    description: TolerationSeconds represents the period of time the
                      toleration (which must be of effect NoExecute, otherwise this
                      field is ignored) tolerates the taint. By default, it is not
                      set, which means tolerate the taint forever (do not evict).
                      Zero and negative values will be treated as 0 (evict immediately)
                      by the system.
                    format: int64
                    type: integer
                  value:
                    description: Value is the taint value the toleration matches to.
                      If the operator is Exists, the value should be empty, otherwise
                      just a regular string.
                    type: string
              type: array
            version:
              description: Version of Prometheus to be deployed.
              type: string
        status:
          description: 'Most recent observed status of the Prometheus cluster. Read-only.
            Not included when requesting from the apiserver, only from the Prometheus
            Operator API itself. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#spec-and-status'
          properties:
            availableReplicas:
              description: Total number of available pods (ready for at least minReadySeconds)
                targeted by this Prometheus deployment.
              format: int32
              type: integer
            paused:
              description: Represents whether any actions on the underlaying managed
                objects are being performed. Only delete actions will be performed.
              type: boolean
            replicas:
              description: Total number of non-terminated pods targeted by this Prometheus
                deployment (their labels match the selector).
              format: int32
              type: integer
            unavailableReplicas:
              description: Total number of unavailable pods targeted by this Prometheus
                deployment.
              format: int32
              type: integer
            updatedReplicas:
              description: Total number of non-terminated pods targeted by this Prometheus
                deployment that have the desired version spec.
              format: int32
              type: integer
          required:
          - paused
          - replicas
          - updatedReplicas
          - availableReplicas
          - unavailableReplicas
      required:
      - spec
  version: v1
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: null
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  creationTimestamp: null
  name: servicemonitors.monitoring.coreos.com
spec:
  group: monitoring.coreos.com
  names:
    kind: ServiceMonitor
    plural: servicemonitors
  scope: Namespaced
  validation:
    openAPIV3Schema:
      description: ServiceMonitor defines monitoring for a set of services.
      properties:
        apiVersion:
          description: 'APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
          type: string
        kind:
          description: 'Kind is a string value representing the REST resource this
            object represents. Servers may infer this from the endpoint the client
            submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds'
          type: string
        spec:
          description: ServiceMonitorSpec contains specification parameters for a
            ServiceMonitor.
          properties:
            endpoints:
              description: A list of endpoints allowed as part of this ServiceMonitor.
              items:
                description: Endpoint defines a scrapeable endpoint serving Prometheus
                  metrics.
                properties:
                  basicAuth:
                    description: 'BasicAuth allow an endpoint to authenticate over
                      basic authentication More info: https://prometheus.io/docs/operating/configuration/#endpoints'
                    properties:
                      password:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                      username:
                        description: SecretKeySelector selects a key of a Secret.
                        properties:
                          key:
                            description: The key of the secret to select from.  Must
                              be a valid secret key.
                            type: string
                          name:
                            description: 'Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names'
                            type: string
                          optional:
                            description: Specify whether the Secret or it's key must
                              be defined
                            type: boolean
                        required:
                        - key
                  bearerTokenFile:
                    description: File to read bearer token for scraping targets.
                    type: string
                  honorLabels:
                    description: HonorLabels chooses the metric's labels on collisions
                      with target labels.
                    type: boolean
                  interval:
                    description: Interval at which metrics should be scraped
                    type: string
                  metricRelabelings:
                    description: MetricRelabelConfigs to apply to samples before ingestion.
                    items:
                      description: 'RelabelConfig allows dynamic rewriting of the
                        label set, being applied to samples before ingestion. It defines
                        `<metric_relabel_configs>`-section of Prometheus configuration.
                        More info: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs'
                      properties:
                        action:
                          description: Action to perform based on regex matching.
                            Default is 'replace'
                          type: string
                        modulus:
                          description: Modulus to take of the hash of the source label
                            values.
                          format: int64
                          type: integer
                        regex:
                          description: Regular expression against which the extracted
                            value is matched. defailt is '(.*)'
                          type: string
                        replacement:
                          description: Replacement value against which a regex replace
                            is performed if the regular expression matches. Regex
                            capture groups are available. Default is '$1'
                          type: string
                        separator:
                          description: Separator placed between concatenated source
                            label values. default is ';'.
                          type: string
                        sourceLabels:
                          description: The source labels select values from existing
                            labels. Their content is concatenated using the configured
                            separator and matched against the configured regular expression
                            for the replace, keep, and drop actions.
                          items:
                            type: string
                          type: array
                        targetLabel:
                          description: Label to which the resulting value is written
                            in a replace action. It is mandatory for replace actions.
                            Regex capture groups are available.
                          type: string
                    type: array
                  params:
                    description: Optional HTTP URL parameters
                    type: object
                  path:
                    description: HTTP path to scrape for metrics.
                    type: string
                  port:
                    description: Name of the service port this endpoint refers to.
                      Mutually exclusive with targetPort.
                    type: string
                  scheme:
                    description: HTTP scheme to use for scraping.
                    type: string
                  scrapeTimeout:
                    description: Timeout after which the scrape is ended
                    type: string
                  targetPort: {}
                  tlsConfig:
                    description: TLSConfig specifies TLS configuration parameters.
                    properties:
                      caFile:
                        description: The CA cert to use for the targets.
                        type: string
                      certFile:
                        description: The client cert file for the targets.
                        type: string
                      insecureSkipVerify:
                        description: Disable target certificate validation.
                        type: boolean
                      keyFile:
                        description: The client key file for the targets.
                        type: string
                      serverName:
                        description: Used to verify the hostname for the targets.
                        type: string
              type: array
            jobLabel:
              description: The label to use to retrieve the job name from.
              type: string
            namespaceSelector:
              description: A selector for selecting namespaces either selecting all
                namespaces or a list of namespaces.
              properties:
                any:
                  description: Boolean describing whether all namespaces are selected
                    in contrast to a list restricting them.
                  type: boolean
                matchNames:
                  description: List of namespace names.
                  items:
                    type: string
                  type: array
            selector:
              description: A label selector is a label query over a set of resources.
                The result of matchLabels and matchExpressions are ANDed. An empty
                label selector matches all objects. A null label selector matches
                no objects.
              properties:
                matchExpressions:
                  description: matchExpressions is a list of label selector requirements.
                    The requirements are ANDed.
                  items:
                    description: A label selector requirement is a selector that contains
                      values, a key, and an operator that relates the key and values.
                    properties:
                      key:
                        description: key is the label key that the selector applies
                          to.
                        type: string
                      operator:
                        description: operator represents a key's relationship to a
                          set of values. Valid operators are In, NotIn, Exists and
                          DoesNotExist.
                        type: string
                      values:
                        description: values is an array of string values. If the operator
                          is In or NotIn, the values array must be non-empty. If the
                          operator is Exists or DoesNotExist, the values array must
                          be empty. This array is replaced during a strategic merge
                          patch.
                        items:
                          type: string
                        type: array
                    required:
                    - key
                    - operator
                  type: array
                matchLabels:
                  description: matchLabels is a map of {key,value} pairs. A single
                    {key,value} in the matchLabels map is equivalent to an element
                    of matchExpressions, whose key field is "key", the operator is
                    "In", and the values array contains only "value". The requirements
                    are ANDed.
                  type: object
            targetLabels:
              description: TargetLabels transfers labels on the Kubernetes Service
                onto the target.
              items:
                type: string
              type: array
          required:
          - endpoints
          - selector
      required:
      - spec
  version: v1
status:
  acceptedNames:
    kind: ""
    plural: ""
  conditions: null
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-operator
rules:
- apiGroups:
  - extensions
  resources:
  - thirdpartyresources
  verbs:
  - '*'
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - '*'
- apiGroups:
  - monitoring.coreos.com
  resources:
  - alertmanagers
  - prometheuses
  - prometheuses/finalizers
  - alertmanagers/finalizers
  - servicemonitors
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - list
  - delete
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  verbs:
  - get
  - create
  - update
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-operator-monitoring
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-operator
subjects:
- kind: ServiceAccount
  name: prometheus-operator
  namespace: tooling
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    k8s-app: prometheus-operator
  name: prometheus-operator
  namespace: tooling
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: prometheus-operator
  template:
    metadata:
      labels:
        k8s-app: prometheus-operator
    spec:
      containers:
      - args:
        - --kubelet-service=kube-system/kubelet
        - --config-reloader-image=quay.io/coreos/configmap-reload:v0.0.1
        image: quay.io/coreos/prometheus-operator:v0.19.0
        name: prometheus-operator
        ports:
        - containerPort: 8080
          name: http
        resources:
          limits:
            cpu: 200m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 50Mi
      nodeSelector:
        kops.k8s.io/instancegroup: tooling
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: prometheus-operator
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: prometheus-operator
  name: prometheus-operator
  namespace: tooling
spec:
  clusterIP: None
  ports:
  - name: http
    port: 8080
    targetPort: http
  selector:
    k8s-app: prometheus-operator
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-operator
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  labels:
    alertmanager: main
  name: main
  namespace: tooling
spec:
  baseImage: quay.io/prometheus/alertmanager
  nodeSelector:
    kops.k8s.io/instancegroup: tooling
  replicas: 3
  serviceAccountName: alertmanager-main
  version: v0.14.0
---
apiVersion: v1
data:
  alertmanager.yaml: Cmdsb2JhbDoKICByZXNvbHZlX3RpbWVvdXQ6IDVtCnJvdXRlOgogIGdyb3VwX2J5OiBbJ2pvYiddCiAgZ3JvdXBfd2FpdDogMzBzCiAgZ3JvdXBfaW50ZXJ2YWw6IDVtCiAgcmVwZWF0X2ludGVydmFsOiAxMmgKICByZWNlaXZlcjogJ251bGwnCiAgcm91dGVzOgogIC0gbWF0Y2g6CiAgICAgIGFsZXJ0bmFtZTogRGVhZE1hbnNTd2l0Y2gKICAgIHJlY2VpdmVyOiAnbnVsbCcKcmVjZWl2ZXJzOgotIG5hbWU6ICdudWxsJwo=
kind: Secret
metadata:
  name: alertmanager-main
  namespace: tooling
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  labels:
    alertmanager: main
  name: alertmanager-main
  namespace: tooling
spec:
  ports:
  - name: web
    port: 9093
    targetPort: web
  selector:
    alertmanager: main
    app: alertmanager
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: alertmanager-main
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: alertmanager
  name: alertmanager
  namespace: tooling
spec:
  endpoints:
  - interval: 30s
    port: web
  namespaceSelector:
    matchNames:
    - tooling
  selector:
    matchLabels:
      alertmanager: main
---
apiVersion: v1
data:
  prometheus.yaml: |-
    {
        "datasources": [
            {
                "access": "proxy",
                "etitable": false,
                "name": "prometheus",
                "org_id": 1,
                "type": "prometheus",
                "url": "http://prometheus-k8s.tooling.svc:9090",
                "version": 1
            }
        ]
    }
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: tooling
---
apiVersion: v1
data:
  k8s-cluster-rsrc-use.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [

        ],
        "refresh": "10s",
        "rows": [
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 0,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_cpu_utilisation:avg1m * node:node_num_cpu:sum / scalar(sum(node:node_num_cpu:sum))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 1,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_cpu_saturation_load1: / scalar(sum(min(kube_pod_info) by (node)))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Saturation (Load1)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 2,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_memory_utilisation:ratio",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 3,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_memory_swap_io_bytes:sum_rate",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Saturation (Swap I/O)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 4,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_disk_utilisation:avg_irate / scalar(:kube_pod_info_node_count:)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk IO Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 5,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_disk_saturation:avg_irate / scalar(:kube_pod_info_node_count:)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk IO Saturation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Disk",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 6,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_net_utilisation:sum_irate",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Net Utilisation (Transmitted)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 7,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_net_saturation:sum_irate",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Net Saturation (Dropped)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Network",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 8,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(max(node_filesystem_size{fstype=\u007e\"ext[24]\"} - node_filesystem_avail{fstype=\u007e\"ext[24]\"}) by (device,pod,namespace)) by (pod,namespace) / scalar(sum(max(node_filesystem_size{fstype=\u007e\"ext[24]\"}) by (device,pod,namespace))) * on (namespace, pod) group_left(node) node_namespace_pod:kube_pod_info:\n",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{node}}",
                                "legendLink": "/dashboard/file/k8s-node-rsrc-use.json",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk Capacity",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": 1,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Storage",
                "titleSize": "h6"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "utc",
        "title": "K8s / USE Method / Cluster",
        "version": 0
    }
  k8s-node-rsrc-use.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [

        ],
        "refresh": "10s",
        "rows": [
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 0,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_cpu_utilisation:avg1m{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Utilisation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 1,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_cpu_saturation_load1:{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Saturation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Saturation (Load1)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 2,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_memory_utilisation:{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Memory",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 3,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_memory_swap_io_bytes:sum_rate{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Swap IO",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Saturation (Swap I/O)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 4,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_disk_utilisation:avg_irate{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Utilisation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk IO Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 5,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_disk_saturation:avg_irate{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Saturation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk IO Saturation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Disk",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 6,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_net_utilisation:sum_irate{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Utilisation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Net Utilisation (Transmitted)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 7,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node:node_net_saturation:sum_irate{node=\"$node\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Saturation",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Net Saturation (Dropped)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "Bps",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Net",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 8,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "1 - sum(max by (device, node) (node_filesystem_avail{fstype=\u007e\"ext[24]\"})) / sum(max by (device, node) (node_filesystem_size{fstype=\u007e\"ext[24]\"}))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Disk",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk Utilisation",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percentunit",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Disk",
                "titleSize": "h6"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {
                        "text": "prod",
                        "value": "prod"
                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "node",
                    "multi": false,
                    "name": "node",
                    "options": [

                    ],
                    "query": "label_values(kube_node_info, node)",
                    "refresh": 1,
                    "regex": "",
                    "sort": 2,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "utc",
        "title": "K8s / USE Method / Node",
        "version": 0
    }
  k8s-resources-cluster.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [

        ],
        "refresh": "10s",
        "rows": [
            {
                "collapse": false,
                "height": "100px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "format": "percentunit",
                        "id": 0,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 3,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(kube_pod_container_resource_requests_cpu_cores) / sum(node:node_num_cpu:sum)",
                                "format": "time_series",
                                "instant": true,
                                "intervalFactor": 2,
                                "refId": "A"
                            }
                        ],
                        "thresholds": "70,80",
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Requests Commitment",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "singlestat",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "format": "percentunit",
                        "id": 1,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 3,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(kube_pod_container_resource_limits_cpu_cores) / sum(node:node_num_cpu:sum)",
                                "format": "time_series",
                                "instant": true,
                                "intervalFactor": 2,
                                "refId": "A"
                            }
                        ],
                        "thresholds": "70,80",
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Limits Commitment",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "singlestat",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "format": "percentunit",
                        "id": 2,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 3,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(kube_pod_container_resource_requests_memory_bytes) / sum(node_memory_MemTotal)",
                                "format": "time_series",
                                "instant": true,
                                "intervalFactor": 2,
                                "refId": "A"
                            }
                        ],
                        "thresholds": "70,80",
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Requests Commitment",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "singlestat",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "format": "percentunit",
                        "id": 3,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 3,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(kube_pod_container_resource_limits_memory_bytes) / sum(node_memory_MemTotal)",
                                "format": "time_series",
                                "instant": true,
                                "intervalFactor": 2,
                                "refId": "A"
                            }
                        ],
                        "thresholds": "70,80",
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Limits Commitment",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "singlestat",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Headlines",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 4,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(irate(container_cpu_usage_seconds_total[1m])) by (namespace)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{namespace}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 5,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "CPU Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "CPU Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Namespace",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": true,
                                "linkTooltip": "Drill down",
                                "linkUrl": "/dashboard/file/k8s-resources-namespace.json?var-datasource=$datasource&var-namespace=$__cell",
                                "pattern": "namespace",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_cpu_cores) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace) / sum(kube_pod_container_resource_requests_cpu_cores) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_cpu_cores) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace) / sum(kube_pod_container_resource_limits_cpu_cores) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Quota",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU Quota",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 6,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(container_memory_rss) by (namespace)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{namespace}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Usage (w/o cache)",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "decbytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 7,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "Memory Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Memory Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Namespace",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": true,
                                "linkTooltip": "Drill down",
                                "linkUrl": "/dashboard/file/k8s-resources-namespace.json?var-datasource=$datasource&var-namespace=$__cell",
                                "pattern": "namespace",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(container_memory_rss) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_memory_bytes) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(container_memory_rss) by (namespace) / sum(kube_pod_container_resource_requests_memory_bytes) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_memory_bytes) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(container_memory_rss) by (namespace) / sum(kube_pod_container_resource_limits_memory_bytes) by (namespace)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Requests by Namespace",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory Requests",
                "titleSize": "h6"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "utc",
        "title": "K8s / Compute Resources / Cluster",
        "version": 0
    }
  k8s-resources-namespace.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [

        ],
        "refresh": "10s",
        "rows": [
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 0,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(irate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[1m])) by (pod_name)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{pod_name}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU Usage",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 1,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "CPU Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "CPU Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Pod",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": true,
                                "linkTooltip": "Drill down",
                                "linkUrl": "/dashboard/file/k8s-resources-pod.json?var-datasource=$datasource&var-namespace=$namespace&var-pod=$__cell",
                                "pattern": "pod",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[5m]), \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_cpu_cores{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[5m]), \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod) / sum(kube_pod_container_resource_requests_cpu_cores{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_cpu_cores{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[5m]), \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod) / sum(kube_pod_container_resource_limits_cpu_cores{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Quota",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU Quota",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 2,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(container_memory_usage_bytes{namespace=\"$namespace\"}) by (pod_name)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{pod_name}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory Usage",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 3,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "Memory Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Memory Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Pod",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": true,
                                "linkTooltip": "Drill down",
                                "linkUrl": "/dashboard/file/k8s-resources-pod.json?var-datasource=$datasource&var-namespace=$namespace&var-pod=$__cell",
                                "pattern": "pod",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\"}, \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_memory_bytes{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\"}, \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod) / sum(kube_pod_container_resource_requests_memory_bytes{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_memory_bytes{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\"}, \"pod\", \"$1\", \"pod_name\", \"(.*)\")) by (pod) / sum(kube_pod_container_resource_limits_memory_bytes{namespace=\"$namespace\"}) by (pod)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Quota",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory Quota",
                "titleSize": "h6"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {
                        "text": "prod",
                        "value": "prod"
                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "namespace",
                    "multi": false,
                    "name": "namespace",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_info, namespace)",
                    "refresh": 1,
                    "regex": "",
                    "sort": 2,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "utc",
        "title": "K8s / Compute Resources / Namespace",
        "version": 0
    }
  k8s-resources-pod.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": true,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "links": [

        ],
        "refresh": "10s",
        "rows": [
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 0,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(irate(container_cpu_usage_seconds_total{namespace=\"$namespace\",pod_name=\"$pod\"}[1m])) by (container_name)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{container_name}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU Usage",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 1,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "CPU Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "CPU Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "CPU Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Container",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "container",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\", pod_name=\"$pod\"}[5m]), \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_cpu_cores{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\", pod_name=\"$pod\"}[5m]), \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container) / sum(kube_pod_container_resource_requests_cpu_cores{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_cpu_cores{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\", pod_name=\"$pod\"}[5m]), \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container) / sum(kube_pod_container_resource_limits_cpu_cores{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Quota",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "CPU Quota",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 10,
                        "id": 2,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 0,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": true,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum(container_memory_usage_bytes{namespace=\"$namespace\", pod_name=\"$pod\"}) by (container_name)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{container_name}}",
                                "legendLink": null,
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory Usage",
                "titleSize": "h6"
            },
            {
                "collapse": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "id": 3,
                        "legend": {
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "links": [

                        ],
                        "nullPointMode": "null as zero",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "styles": [
                            {
                                "alias": "Time",
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "pattern": "Time",
                                "type": "hidden"
                            },
                            {
                                "alias": "Memory Usage",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #A",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #B",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Requests %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #C",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Memory Limits",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #D",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "decbytes"
                            },
                            {
                                "alias": "Memory Limits %",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "Value #E",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "percentunit"
                            },
                            {
                                "alias": "Container",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "link": false,
                                "linkTooltip": "Drill down",
                                "linkUrl": "",
                                "pattern": "container",
                                "thresholds": [

                                ],
                                "type": "number",
                                "unit": "short"
                            },
                            {
                                "alias": "",
                                "colorMode": null,
                                "colors": [

                                ],
                                "dateFormat": "YYYY-MM-DD HH:mm:ss",
                                "decimals": 2,
                                "pattern": "/.*/",
                                "thresholds": [

                                ],
                                "type": "string",
                                "unit": "short"
                            }
                        ],
                        "targets": [
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\", pod_name=\"$pod\"}, \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_requests_memory_bytes{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\", pod_name=\"$pod\"}, \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container) / sum(kube_pod_container_resource_requests_memory_bytes{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(kube_pod_container_resource_limits_memory_bytes{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            },
                            {
                                "expr": "sum(label_replace(container_memory_usage_bytes{namespace=\"$namespace\", pod_name=\"$pod\"}, \"container\", \"$1\", \"container_name\", \"(.*)\")) by (container) / sum(kube_pod_container_resource_limits_memory_bytes{namespace=\"$namespace\", pod=\"$pod\"}) by (container)",
                                "format": "table",
                                "instant": true,
                                "intervalFactor": 2,
                                "legendFormat": "",
                                "step": 10
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Quota",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "transform": "table",
                        "type": "table",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": false
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": true,
                "title": "Memory Quota",
                "titleSize": "h6"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {
                        "text": "prod",
                        "value": "prod"
                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "namespace",
                    "multi": false,
                    "name": "namespace",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_info, namespace)",
                    "refresh": 1,
                    "regex": "",
                    "sort": 2,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                },
                {
                    "allValue": null,
                    "current": {
                        "text": "prod",
                        "value": "prod"
                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "pod",
                    "multi": false,
                    "name": "pod",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_info{namespace=\"$namespace\"}, pod)",
                    "refresh": 1,
                    "regex": "",
                    "sort": 2,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "utc",
        "title": "K8s / Compute Resources / Pod",
        "version": 0
    }
  nodes.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": false,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "id": null,
        "links": [

        ],
        "refresh": "",
        "rows": [
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 2,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "100 - (avg by (cpu) (irate(node_cpu{job=\"node-exporter\", mode=\"idle\", instance=\"$instance\"}[5m])) * 100)\n",
                                "format": "time_series",
                                "intervalFactor": 10,
                                "legendFormat": "{{cpu}}",
                                "refId": "A"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Idle CPU",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percent",
                                "label": null,
                                "logBase": 1,
                                "max": 100,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "percent",
                                "label": null,
                                "logBase": 1,
                                "max": 100,
                                "min": 0,
                                "show": true
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 3,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node_load1{job=\"node-exporter\", instance=\"$instance\"} * 100",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "load 1m",
                                "refId": "A"
                            },
                            {
                                "expr": "node_load5{job=\"node-exporter\", instance=\"$instance\"} * 100",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "load 5m",
                                "refId": "B"
                            },
                            {
                                "expr": "node_load15{job=\"node-exporter\", instance=\"$instance\"} * 100",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "load 15m",
                                "refId": "C"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "System load",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "percent",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "percent",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 4,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 9,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "node_memory_MemTotal{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_MemFree{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_Buffers{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_Cached{job=\"node-exporter\", instance=\"$instance\"}\n",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "memory used",
                                "refId": "A"
                            },
                            {
                                "expr": "node_memory_Buffers{job=\"node-exporter\", instance=\"$instance\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "memory buffers",
                                "refId": "B"
                            },
                            {
                                "expr": "node_memory_Cached{job=\"node-exporter\", instance=\"$instance\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "memory cached",
                                "refId": "C"
                            },
                            {
                                "expr": "node_memory_MemFree{job=\"node-exporter\", instance=\"$instance\"}",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "memory free",
                                "refId": "D"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "rgba(50, 172, 45, 0.97)",
                            "rgba(237, 129, 40, 0.89)",
                            "rgba(245, 54, 54, 0.9)"
                        ],
                        "datasource": "prometheus",
                        "format": "percent",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": true,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 5,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "(\n  node_memory_MemTotal{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_MemFree{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_Buffers{job=\"node-exporter\", instance=\"$instance\"}\n- node_memory_Cached{job=\"node-exporter\", instance=\"$instance\"}\n) * 100\n  /\nnode_memory_MemTotal{job=\"node-exporter\", instance=\"$instance\"}\n",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "80, 90",
                        "title": "Memory Usage",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "N/A",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 6,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [
                            {
                                "alias": "read",
                                "yaxis": 1
                            },
                            {
                                "alias": "io time",
                                "yaxis": 2
                            }
                        ],
                        "spaceLength": 10,
                        "span": 9,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum by (instance) (rate(node_disk_bytes_read{job=\"node-exporter\", instance=\"$instance\"}[2m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "read",
                                "refId": "A"
                            },
                            {
                                "expr": "sum by (instance) (rate(node_disk_bytes_written{job=\"node-exporter\", instance=\"$instance\"}[2m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "written",
                                "refId": "B"
                            },
                            {
                                "expr": "sum by (instance) (rate(node_disk_io_time_ms{job=\"node-exporter\",  instance=\"$instance\"}[2m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "io time",
                                "refId": "C"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Disk I/O",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "ms",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "rgba(50, 172, 45, 0.97)",
                            "rgba(237, 129, 40, 0.89)",
                            "rgba(245, 54, 54, 0.9)"
                        ],
                        "datasource": "prometheus",
                        "format": "percent",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": true,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 7,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "(\n  sum(node_filesystem_size{job=\"node-exporter\", device!=\"rootfs\", instance=\"$instance\"})\n- sum(node_filesystem_avail{job=\"node-exporter\", device!=\"rootfs\", instance=\"$instance\"})\n) * 100\n  /\nsum(node_filesystem_size{job=\"node-exporter\", device!=\"rootfs\", instance=\"$instance\"})\n",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "80, 90",
                        "title": "Disk Space Usage",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "N/A",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 8,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "rate(node_network_receive_bytes{job=\"node-exporter\", instance=\"$instance\", device!\u007e\"lo\"}[5m])",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{device}}",
                                "refId": "A"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Network Received",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    },
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 9,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 6,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "rate(node_network_transmit_bytes{job=\"node-exporter\", instance=\"$instance\", device!\u007e\"lo\"}[5m])",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{device}}",
                                "refId": "A"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Network Transmitted",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": null,
                    "multi": false,
                    "name": "instance",
                    "options": [

                    ],
                    "query": "label_values(node_boot_time{job=\"node-exporter\"}, instance)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "browser",
        "title": "Nodes",
        "version": 0
    }
  pods.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": false,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "id": null,
        "links": [

        ],
        "refresh": "",
        "rows": [
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 2,
                        "legend": {
                            "alignAsTable": true,
                            "avg": true,
                            "current": true,
                            "max": false,
                            "min": false,
                            "rightSide": true,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum by(container_name) (container_memory_usage_bytes{job=\"kubelet\", namespace=\"$namespace\", pod_name=\"$pod\", container_name=\u007e\"$container\", container_name!=\"POD\"})",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Current: {{ container_name }}",
                                "refId": "A"
                            },
                            {
                                "expr": "sum by(container) (kube_pod_container_resource_requests_memory_bytes{job=\"kubelet\", namespace=\"$namespace\", pod=\"$pod\", container=\u007e\"$container\", container!=\"POD\"})",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Requested: {{ container }}",
                                "refId": "B"
                            },
                            {
                                "expr": "sum by(container) (kube_pod_container_resource_limits_memory_bytes{job=\"kubelet\", namespace=\"$namespace\", pod=\"$pod\", container=\u007e\"$container\", container!=\"POD\"})",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "Limit: {{ container }}",
                                "refId": "C"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Memory Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 3,
                        "legend": {
                            "alignAsTable": true,
                            "avg": true,
                            "current": true,
                            "max": false,
                            "min": false,
                            "rightSide": true,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sum by (container_name) (rate(container_cpu_usage_seconds_total{job=\"kubelet\", image!=\"\",container_name!=\"POD\",pod_name=\"$pod\"}[1m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{ container_name }}",
                                "refId": "A"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "CPU Usage",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "$datasource",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 4,
                        "legend": {
                            "alignAsTable": true,
                            "avg": true,
                            "current": true,
                            "max": false,
                            "min": false,
                            "rightSide": true,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "sort_desc(sum by (pod_name) (rate(container_network_receive_bytes_total{job=\"kubelet\", pod_name=\"$pod\"}[1m])))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "{{ pod_name }}",
                                "refId": "A"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Network I/O",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            },
                            {
                                "format": "bytes",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": 0,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "Namespace",
                    "multi": false,
                    "name": "namespace",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_info, namespace)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": false,
                    "label": "Pod",
                    "multi": false,
                    "name": "pod",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_info{namespace=\u007e\"$namespace\"}, pod)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "$datasource",
                    "hide": 0,
                    "includeAll": true,
                    "label": "Container",
                    "multi": false,
                    "name": "container",
                    "options": [

                    ],
                    "query": "label_values(kube_pod_container_info{namespace=\"$namespace\", pod=\"$pod\"}, container)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "browser",
        "title": "Pods",
        "version": 0
    }
  statefulset.json: |-
    {
        "annotations": {
            "list": [

            ]
        },
        "editable": false,
        "gnetId": null,
        "graphTooltip": 0,
        "hideControls": false,
        "id": null,
        "links": [

        ],
        "refresh": "",
        "rows": [
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 2,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "cores",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 4,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "lineColor": "rgb(31, 120, 193)",
                            "show": true
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "sum(rate(container_cpu_usage_seconds_total{job=\"kubelet\", namespace=\"$namespace\", pod_name=\u007e\"$statefulset.*\"}[3m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "CPU",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 3,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "GB",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 4,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "lineColor": "rgb(31, 120, 193)",
                            "show": true
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "sum(container_memory_usage_bytes{job=\"kubelet\", namespace=\"$namespace\", pod_name=\u007e\"$statefulset.*\"}) / 1024^3",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Memory",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 4,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "Bps",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 4,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "lineColor": "rgb(31, 120, 193)",
                            "show": true
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "sum(rate(container_network_transmit_bytes_total{job=\"kubelet\", namespace=\"$namespace\", pod_name=\u007e\"$statefulset.*\"}[3m])) + sum(rate(container_network_receive_bytes_total{namespace=\"$namespace\",pod_name=\u007e\"$statefulset.*\"}[3m]))",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Network",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "100px",
                "panels": [
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 5,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "max(kube_statefulset_replicas{job=\"kube-state-metrics\", namespace=\"$namespace\", statefulset=\"$statefulset\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Desired Replicas",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 6,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "min(kube_statefulset_status_replicas_current{job=\"kube-state-metrics\", namespace=\"$namespace\", statefulset=\"$statefulset\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Replicas of current version",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 7,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "max(kube_statefulset_status_observed_generation{job=\"kube-state-metrics\",  namespace=\"$namespace\", statefulset=\"$statefulset\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Observed Generation",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    },
                    {
                        "cacheTimeout": null,
                        "colorBackground": false,
                        "colorValue": false,
                        "colors": [
                            "#299c46",
                            "rgba(237, 129, 40, 0.89)",
                            "#d44a3a"
                        ],
                        "datasource": "prometheus",
                        "format": "none",
                        "gauge": {
                            "maxValue": 100,
                            "minValue": 0,
                            "show": false,
                            "thresholdLabels": false,
                            "thresholdMarkers": true
                        },
                        "gridPos": {

                        },
                        "id": 8,
                        "interval": null,
                        "links": [

                        ],
                        "mappingType": 1,
                        "mappingTypes": [
                            {
                                "name": "value to text",
                                "value": 1
                            },
                            {
                                "name": "range to text",
                                "value": 2
                            }
                        ],
                        "maxDataPoints": 100,
                        "nullPointMode": "connected",
                        "nullText": null,
                        "postfix": "",
                        "postfixFontSize": "50%",
                        "prefix": "",
                        "prefixFontSize": "50%",
                        "rangeMaps": [
                            {
                                "from": "null",
                                "text": "N/A",
                                "to": "null"
                            }
                        ],
                        "span": 3,
                        "sparkline": {
                            "fillColor": "rgba(31, 118, 189, 0.18)",
                            "full": false,
                            "lineColor": "rgb(31, 120, 193)",
                            "show": false
                        },
                        "tableColumn": "",
                        "targets": [
                            {
                                "expr": "max(kube_statefulset_metadata_generation{job=\"kube-state-metrics\", statefulset=\"$statefulset\", namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": ""
                            }
                        ],
                        "thresholds": "",
                        "title": "Metadata Generation",
                        "type": "singlestat",
                        "valueFontSize": "80%",
                        "valueMaps": [
                            {
                                "op": "=",
                                "text": "0",
                                "value": "null"
                            }
                        ],
                        "valueName": "current"
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            },
            {
                "collapse": false,
                "collapsed": false,
                "height": "250px",
                "panels": [
                    {
                        "aliasColors": {

                        },
                        "bars": false,
                        "dashLength": 10,
                        "dashes": false,
                        "datasource": "prometheus",
                        "fill": 1,
                        "gridPos": {

                        },
                        "id": 9,
                        "legend": {
                            "alignAsTable": false,
                            "avg": false,
                            "current": false,
                            "max": false,
                            "min": false,
                            "rightSide": false,
                            "show": true,
                            "total": false,
                            "values": false
                        },
                        "lines": true,
                        "linewidth": 1,
                        "nullPointMode": "null",
                        "percentage": false,
                        "pointradius": 5,
                        "points": false,
                        "renderer": "flot",
                        "repeat": null,
                        "seriesOverrides": [

                        ],
                        "spaceLength": 10,
                        "span": 12,
                        "stack": false,
                        "steppedLine": false,
                        "targets": [
                            {
                                "expr": "max(kube_statefulset_replicas{job=\"kube-state-metrics\", statefulset=\"$statefulset\",namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "replicas specified",
                                "refId": "A"
                            },
                            {
                                "expr": "max(kube_statefulset_status_replicas{job=\"kube-state-metrics\", statefulset=\"$statefulset\",namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "replicas created",
                                "refId": "B"
                            },
                            {
                                "expr": "min(kube_statefulset_status_replicas_ready{job=\"kube-state-metrics\", statefulset=\"$statefulset\",namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "ready",
                                "refId": "C"
                            },
                            {
                                "expr": "min(kube_statefulset_status_replicas_current{job=\"kube-state-metrics\", statefulset=\"$statefulset\",namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "replicas of current version",
                                "refId": "D"
                            },
                            {
                                "expr": "min(kube_statefulset_status_replicas_updated{job=\"kube-state-metrics\", statefulset=\"$statefulset\",namespace=\"$namespace\"}) without (instance, pod)",
                                "format": "time_series",
                                "intervalFactor": 2,
                                "legendFormat": "updated",
                                "refId": "E"
                            }
                        ],
                        "thresholds": [

                        ],
                        "timeFrom": null,
                        "timeShift": null,
                        "title": "Replicas",
                        "tooltip": {
                            "shared": true,
                            "sort": 0,
                            "value_type": "individual"
                        },
                        "type": "graph",
                        "xaxis": {
                            "buckets": null,
                            "mode": "time",
                            "name": null,
                            "show": true,
                            "values": [

                            ]
                        },
                        "yaxes": [
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            },
                            {
                                "format": "short",
                                "label": null,
                                "logBase": 1,
                                "max": null,
                                "min": null,
                                "show": true
                            }
                        ]
                    }
                ],
                "repeat": null,
                "repeatIteration": null,
                "repeatRowId": null,
                "showTitle": false,
                "title": "Dashboard Row",
                "titleSize": "h6",
                "type": "row"
            }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [

        ],
        "templating": {
            "list": [
                {
                    "current": {
                        "text": "Prometheus",
                        "value": "Prometheus"
                    },
                    "hide": 0,
                    "label": null,
                    "name": "datasource",
                    "options": [

                    ],
                    "query": "prometheus",
                    "refresh": 1,
                    "regex": "",
                    "type": "datasource"
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "prometheus",
                    "hide": 0,
                    "includeAll": false,
                    "label": "Namespace",
                    "multi": false,
                    "name": "namespace",
                    "options": [

                    ],
                    "query": "label_values(kube_statefulset_metadata_generation{job=\"kube-state-metrics\"}, namespace)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                },
                {
                    "allValue": null,
                    "current": {

                    },
                    "datasource": "prometheus",
                    "hide": 0,
                    "includeAll": false,
                    "label": "Name",
                    "multi": false,
                    "name": "statefulset",
                    "options": [

                    ],
                    "query": "label_values(kube_statefulset_metadata_generation{job=\"kube-state-metrics\", namespace=\"$namespace\"}, statefulset)",
                    "refresh": 2,
                    "regex": "",
                    "sort": 0,
                    "tagValuesQuery": "",
                    "tags": [

                    ],
                    "tagsQuery": "",
                    "type": "query",
                    "useTags": false
                }
            ]
        },
        "time": {
            "from": "now-1h",
            "to": "now"
        },
        "timepicker": {
            "refresh_intervals": [
                "5s",
                "10s",
                "30s",
                "1m",
                "5m",
                "15m",
                "30m",
                "1h",
                "2h",
                "1d"
            ],
            "time_options": [
                "5m",
                "15m",
                "1h",
                "6h",
                "12h",
                "24h",
                "2d",
                "7d",
                "30d"
            ]
        },
        "timezone": "browser",
        "title": "StatefulSets",
        "version": 0
    }
kind: ConfigMap
metadata:
  name: grafana-dashboard-definitions
  namespace: tooling
---
apiVersion: v1
data:
  dashboards.yaml: |-
    [
        {
            "folder": "",
            "name": "0",
            "options": {
                "path": "/grafana-dashboard-definitions/0"
            },
            "org_id": 1,
            "type": "file"
        }
    ]
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: tooling
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    app: grafana
  name: grafana
  namespace: tooling
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - image: grafana/grafana:5.1.0
        name: grafana
        ports:
        - containerPort: 3000
          name: http
        resources:
          limits:
            cpu: 200m
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - mountPath: /var/lib/grafana
          name: grafana-storage
          readOnly: false
        - mountPath: /etc/grafana/provisioning/datasources
          name: grafana-datasources
          readOnly: false
        - mountPath: /etc/grafana/provisioning/dashboards
          name: grafana-dashboards
          readOnly: false
        - mountPath: /grafana-dashboard-definitions/0
          name: grafana-dashboard-definitions
          readOnly: false
      nodeSelector:
        kops.k8s.io/instancegroup: tooling
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: grafana
      volumes:
      - emptyDir: {}
        name: grafana-storage
      - configMap:
          name: grafana-datasources
        name: grafana-datasources
      - configMap:
          name: grafana-dashboards
        name: grafana-dashboards
      - configMap:
          name: grafana-dashboard-definitions
        name: grafana-dashboard-definitions
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: tooling
spec:
  ports:
  - name: http
    port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    app: grafana
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  namespace: tooling
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.$CLUSTER_DOMAIN
    http:
      paths:
      - path: /
        backend:
          serviceName: grafana
          servicePort: 3000

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana
  namespace: tooling
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube-state-metrics
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - nodes
  - pods
  - services
  - resourcequotas
  - replicationcontrollers
  - limitranges
  - persistentvolumeclaims
  - persistentvolumes
  - namespaces
  - endpoints
  verbs:
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - replicasets
  verbs:
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs:
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - list
  - watch
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-state-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
  namespace: tooling
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    app: kube-state-metrics
  name: kube-state-metrics
  namespace: tooling
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kube-state-metrics
  template:
    metadata:
      labels:
        app: kube-state-metrics
    spec:
      containers:
      - args:
        - --secure-listen-address=:8443
        - --upstream=http://127.0.0.1:8081/
        image: quay.io/coreos/kube-rbac-proxy:v0.3.0
        name: kube-rbac-proxy-main
        ports:
        - containerPort: 8443
          name: https-main
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
      - args:
        - --secure-listen-address=:9443
        - --upstream=http://127.0.0.1:8082/
        image: quay.io/coreos/kube-rbac-proxy:v0.3.0
        name: kube-rbac-proxy-self
        ports:
        - containerPort: 9443
          name: https-self
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
      - args:
        - --host=127.0.0.1
        - --port=8081
        - --telemetry-host=127.0.0.1
        - --telemetry-port=8082
        image: quay.io/coreos/kube-state-metrics:v1.3.0
        name: kube-state-metrics
        resources:
          limits:
            cpu: 102m
            memory: 180Mi
          requests:
            cpu: 102m
            memory: 180Mi
      - command:
        - /pod_nanny
        - --container=kube-state-metrics
        - --cpu=100m
        - --extra-cpu=2m
        - --memory=150Mi
        - --extra-memory=30Mi
        - --threshold=5
        - --deployment=kube-state-metrics
        env:
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        image: quay.io/coreos/addon-resizer:1.0
        name: addon-resizer
        resources:
          limits:
            cpu: 10m
            memory: 30Mi
          requests:
            cpu: 10m
            memory: 30Mi
      nodeSelector:
        kops.k8s.io/instancegroup: tooling
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: kube-state-metrics
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kube-state-metrics
  namespace: tooling
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - extensions
  resourceNames:
  - kube-state-metrics
  resources:
  - deployments
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kube-state-metrics
  namespace: tooling
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: kube-state-metrics
  name: kube-state-metrics
  namespace: tooling
spec:
  clusterIP: None
  ports:
  - name: https-main
    port: 8443
    targetPort: https-main
  - name: https-self
    port: 9443
    targetPort: https-self
  selector:
    app: kube-state-metrics
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-state-metrics
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: kube-state-metrics
  name: kube-state-metrics
  namespace: tooling
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    honorLabels: true
    interval: 30s
    port: https-main
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: 30s
    port: https-self
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - tooling
  selector:
    matchLabels:
      k8s-app: kube-state-metrics
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-exporter
rules:
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-exporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: node-exporter
subjects:
- kind: ServiceAccount
  name: node-exporter
  namespace: tooling
---
apiVersion: apps/v1beta2
kind: DaemonSet
metadata:
  labels:
    app: node-exporter
  name: node-exporter
  namespace: tooling
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - args:
        - --web.listen-address=127.0.0.1:9101
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        image: quay.io/prometheus/node-exporter:v0.15.2
        name: node-exporter
        resources:
          limits:
            cpu: 102m
            memory: 180Mi
          requests:
            cpu: 102m
            memory: 180Mi
        volumeMounts:
        - mountPath: /host/proc
          name: proc
          readOnly: false
        - mountPath: /host/sys
          name: sys
          readOnly: false
      - args:
        - --secure-listen-address=:9100
        - --upstream=http://127.0.0.1:9101/
        image: quay.io/coreos/kube-rbac-proxy:v0.3.0
        name: kube-rbac-proxy
        ports:
        - containerPort: 9100
          name: https
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
      nodeSelector:
        beta.kubernetes.io/os: linux
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: node-exporter
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
      volumes:
      - hostPath:
          path: /proc
        name: proc
      - hostPath:
          path: /sys
        name: sys
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: node-exporter
  name: node-exporter
  namespace: tooling
spec:
  clusterIP: None
  ports:
  - name: https
    port: 9100
    targetPort: https
  selector:
    app: node-exporter
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: node-exporter
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: node-exporter
  name: node-exporter
  namespace: tooling
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: 30s
    port: https
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - tooling
  selector:
    matchLabels:
      k8s-app: node-exporter
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-k8s
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- nonResourceURLs:
  - /metrics
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-k8s
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-k8s
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  labels:
    prometheus: k8s
  name: k8s
  namespace: tooling
spec:
  alerting:
    alertmanagers:
    - name: alertmanager-main
      namespace: tooling
      port: web
  baseImage: quay.io/prometheus/prometheus
  nodeSelector:
    kops.k8s.io/instancegroup: tooling
  replicas: 2
  resources:
    requests:
      memory: 400Mi
  ruleSelector:
    matchLabels:
      prometheus: k8s
      role: alert-rules
  serviceAccountName: prometheus-k8s
  serviceMonitorSelector:
    matchExpressions:
    - key: k8s-app
      operator: Exists
  version: v2.2.1
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s-config
  namespace: tooling
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s-config
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s
  namespace: tooling
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s-config
  namespace: tooling
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s
  namespace: default
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s
  namespace: kube-system
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s
  namespace: tooling
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: v1
data:
  all.rules.yaml: "\"groups\": \n- \"name\": \"k8s.rules\"\n  \"rules\": \n  - \"expr\":
    |\n      sum(rate(container_cpu_usage_seconds_total{job=\"kubelet\", image!=\"\"}[5m]))
    by (namespace)\n    \"record\": \"namespace:container_cpu_usage_seconds_total:sum_rate\"\n
    \ - \"expr\": |\n      sum(container_memory_usage_bytes{job=\"kubelet\", image!=\"\"})
    by (namespace)\n    \"record\": \"namespace:container_memory_usage_bytes:sum\"\n
    \ - \"expr\": |\n      sum by (namespace, label_name) (\n         sum(rate(container_cpu_usage_seconds_total{job=\"kubelet\",
    image!=\"\"}[5m])) by (namespace, pod_name)\n       * on (namespace, pod_name)
    group_left(label_name)\n         label_replace(kube_pod_labels{job=\"kube-state-metrics\"},
    \"pod_name\", \"$1\", \"pod\", \"(.*)\")\n      )\n    \"record\": \"namespace_name:container_cpu_usage_seconds_total:sum_rate\"\n
    \ - \"expr\": |\n      sum by (namespace, label_name) (\n        sum(container_memory_usage_bytes{job=\"kubelet\",image!=\"\"})
    by (pod_name, namespace)\n      * on (namespace, pod_name) group_left(label_name)\n
    \       label_replace(kube_pod_labels{job=\"kube-state-metrics\"}, \"pod_name\",
    \"$1\", \"pod\", \"(.*)\")\n      )\n    \"record\": \"namespace_name:container_memory_usage_bytes:sum\"\n
    \ - \"expr\": |\n      sum by (namespace, label_name) (\n        sum(kube_pod_container_resource_requests_memory_bytes{job=\"kube-state-metrics\"})
    by (namespace, pod)\n      * on (namespace, pod) group_left(label_name)\n        label_replace(kube_pod_labels{job=\"kube-state-metrics\"},
    \"pod_name\", \"$1\", \"pod\", \"(.*)\")\n      )\n    \"record\": \"namespace_name:kube_pod_container_resource_requests_memory_bytes:sum\"\n
    \ - \"expr\": |\n      sum by (namespace, label_name) (\n        sum(kube_pod_container_resource_requests_cpu_cores{job=\"kube-state-metrics\"})
    by (namespace, pod)\n      * on (namespace, pod) group_left(label_name)\n        label_replace(kube_pod_labels{job=\"kube-state-metrics\"},
    \"pod_name\", \"$1\", \"pod\", \"(.*)\")\n      )\n    \"record\": \"namespace_name:kube_pod_container_resource_requests_cpu_cores:sum\"\n-
    \"name\": \"node.rules\"\n  \"rules\": \n  - \"expr\": \"sum(min(kube_pod_info)
    by (node))\"\n    \"record\": \":kube_pod_info_node_count:\"\n  - \"expr\": |\n
    \     max(label_replace(kube_pod_info{job=\"kube-state-metrics\"}, \"pod\", \"$1\",
    \"pod\", \"(.*)\")) by (node, namespace, pod)\n    \"record\": \"node_namespace_pod:kube_pod_info:\"\n
    \ - \"expr\": |\n      count by (node) (sum by (node, cpu) (\n        node_cpu{job=\"node-exporter\"}\n
    \     * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     ))\n    \"record\": \"node:node_num_cpu:sum\"\n  - \"expr\": |\n      1
    - avg(rate(node_cpu{job=\"node-exporter\",mode=\"idle\"}[1m]))\n    \"record\":
    \":node_cpu_utilisation:avg1m\"\n  - \"expr\": |\n      1 - avg by (node) (\n
    \       rate(node_cpu{job=\"node-exporter\",mode=\"idle\"}[1m])\n      * on (namespace,
    pod) group_left(node)\n        node_namespace_pod:kube_pod_info:)\n    \"record\":
    \"node:node_cpu_utilisation:avg1m\"\n  - \"expr\": |\n      sum(node_load1{job=\"node-exporter\"})\n
    \     /\n      sum(node:node_num_cpu:sum)\n    \"record\": \":node_cpu_saturation_load1:\"\n
    \ - \"expr\": |\n      sum by (node) (\n        node_load1{job=\"node-exporter\"}\n
    \     * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     )\n      /\n      node:node_num_cpu:sum\n    \"record\": \"node:node_cpu_saturation_load1:\"\n
    \ - \"expr\": |\n      1 -\n      sum(node_memory_MemFree{job=\"node-exporter\"}
    + node_memory_Cached{job=\"node-exporter\"} + node_memory_Buffers{job=\"node-exporter\"})\n
    \     /\n      sum(node_memory_MemTotal{job=\"node-exporter\"})\n    \"record\":
    \":node_memory_utilisation:\"\n  - \"expr\": |\n      sum by (node) (\n        (node_memory_MemFree{job=\"node-exporter\"}
    + node_memory_Cached{job=\"node-exporter\"} + node_memory_Buffers{job=\"node-exporter\"})\n
    \       * on (namespace, pod) group_left(node)\n          node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_memory_bytes_available:sum\"\n  - \"expr\":
    |\n      sum by (node) (\n        node_memory_MemTotal{job=\"node-exporter\"}\n
    \       * on (namespace, pod) group_left(node)\n          node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_memory_bytes_total:sum\"\n  - \"expr\": |\n
    \     (node:node_memory_bytes_total:sum - node:node_memory_bytes_available:sum)\n
    \     /\n      scalar(sum(node:node_memory_bytes_total:sum))\n    \"record\":
    \"node:node_memory_utilisation:ratio\"\n  - \"expr\": |\n      1e3 * sum(\n        (rate(node_vmstat_pgpgin{job=\"node-exporter\"}[1m])\n
    \      + rate(node_vmstat_pgpgout{job=\"node-exporter\"}[1m]))\n      )\n    \"record\":
    \":node_memory_swap_io_bytes:sum_rate\"\n  - \"expr\": |\n      1 -\n      sum
    by (node) (\n        (node_memory_MemFree{job=\"node-exporter\"} + node_memory_Cached{job=\"node-exporter\"}
    + node_memory_Buffers{job=\"node-exporter\"})\n      * on (namespace, pod) group_left(node)\n
    \       node_namespace_pod:kube_pod_info:\n      )\n      /\n      sum by (node)
    (\n        node_memory_MemTotal{job=\"node-exporter\"}\n      * on (namespace,
    pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n      )\n    \"record\":
    \"node:node_memory_utilisation:\"\n  - \"expr\": |\n      1 - (node:node_memory_bytes_available:sum
    / node:node_memory_bytes_total:sum)\n    \"record\": \"node:node_memory_utilisation_2:\"\n
    \ - \"expr\": |\n      1e3 * sum by (node) (\n        (rate(node_vmstat_pgpgin{job=\"node-exporter\"}[1m])\n
    \      + rate(node_vmstat_pgpgout{job=\"node-exporter\"}[1m]))\n       * on (namespace,
    pod) group_left(node)\n         node_namespace_pod:kube_pod_info:\n      )\n    \"record\":
    \"node:node_memory_swap_io_bytes:sum_rate\"\n  - \"expr\": |\n      avg(irate(node_disk_io_time_ms{job=\"node-exporter\",device=~\"(sd|xvd).+\"}[1m])
    / 1e3)\n    \"record\": \":node_disk_utilisation:avg_irate\"\n  - \"expr\": |\n
    \     avg by (node) (\n        irate(node_disk_io_time_ms{job=\"node-exporter\",device=~\"(sd|xvd).+\"}[1m])
    / 1e3\n      * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_disk_utilisation:avg_irate\"\n  - \"expr\":
    |\n      avg(irate(node_disk_io_time_weighted{job=\"node-exporter\",device=~\"(sd|xvd).+\"}[1m])
    / 1e3)\n    \"record\": \":node_disk_saturation:avg_irate\"\n  - \"expr\": |\n
    \     avg by (node) (\n        irate(node_disk_io_time_weighted{job=\"node-exporter\",device=~\"(sd|xvd).+\"}[1m])
    / 1e3\n      * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_disk_saturation:avg_irate\"\n  - \"expr\":
    |\n      sum(irate(node_network_receive_bytes{job=\"node-exporter\",device=\"eth0\"}[1m]))
    +\n      sum(irate(node_network_transmit_bytes{job=\"node-exporter\",device=\"eth0\"}[1m]))\n
    \   \"record\": \":node_net_utilisation:sum_irate\"\n  - \"expr\": |\n      sum
    by (node) (\n        (irate(node_network_receive_bytes{job=\"node-exporter\",device=\"eth0\"}[1m])
    +\n        irate(node_network_transmit_bytes{job=\"node-exporter\",device=\"eth0\"}[1m]))\n
    \     * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_net_utilisation:sum_irate\"\n  - \"expr\":
    |\n      sum(irate(node_network_receive_drop{job=\"node-exporter\",device=\"eth0\"}[1m]))
    +\n      sum(irate(node_network_transmit_drop{job=\"node-exporter\",device=\"eth0\"}[1m]))\n
    \   \"record\": \":node_net_saturation:sum_irate\"\n  - \"expr\": |\n      sum
    by (node) (\n        (irate(node_network_receive_drop{job=\"node-exporter\",device=\"eth0\"}[1m])
    +\n        irate(node_network_transmit_drop{job=\"node-exporter\",device=\"eth0\"}[1m]))\n
    \     * on (namespace, pod) group_left(node)\n        node_namespace_pod:kube_pod_info:\n
    \     )\n    \"record\": \"node:node_net_saturation:sum_irate\"\n- \"name\": \"kubernetes-apps\"\n
    \ \"rules\": \n  - \"alert\": \"KubePodCrashLooping\"\n    \"annotations\": \n
    \     \"message\": \"{{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container
    }}) is restarting {{ printf \\\"%.2f\\\" $value }} / second\"\n    \"expr\": |\n
    \     rate(kube_pod_container_status_restarts_total{job=\"kube-state-metrics\"}[15m])
    > 0\n    \"for\": \"1h\"\n    \"labels\": \n      \"severity\": \"critical\"\n
    \ - \"alert\": \"KubePodNotReady\"\n    \"annotations\": \n      \"message\":
    \"{{ $labels.namespace }}/{{ $labels.pod }} is not ready.\"\n    \"expr\": |\n
    \     sum by (namespace, pod) (kube_pod_status_phase{job=\"kube-state-metrics\",
    phase!~\"Running|Succeeded\"}) > 0\n    \"for\": \"1h\"\n    \"labels\": \n      \"severity\":
    \"critical\"\n  - \"alert\": \"KubeDeploymentGenerationMismatch\"\n    \"annotations\":
    \n      \"message\": \"Deployment {{ $labels.namespace }}/{{ $labels.deployment
    }} generation mismatch\"\n    \"expr\": |\n      kube_deployment_status_observed_generation{job=\"kube-state-metrics\"}\n
    \       !=\n      kube_deployment_metadata_generation{job=\"kube-state-metrics\"}\n
    \   \"for\": \"15m\"\n    \"labels\": \n      \"severity\": \"critical\"\n  -
    \"alert\": \"KubeDeploymentReplicasMismatch\"\n    \"annotations\": \n      \"message\":
    \"Deployment {{ $labels.namespace }}/{{ $labels.deployment }} replica mismatch\"\n
    \   \"expr\": |\n      kube_deployment_spec_replicas{job=\"kube-state-metrics\"}\n
    \       !=\n      kube_deployment_status_replicas_available{job=\"kube-state-metrics\"}\n
    \   \"for\": \"15m\"\n    \"labels\": \n      \"severity\": \"critical\"\n- \"name\":
    \"kubernetes-resources\"\n  \"rules\": \n  - \"alert\": \"KubeCPUOvercommit\"\n
    \   \"annotations\": \n      \"message\": \"Overcommited CPU resource requests
    on Pods, cannot tolerate node failure.\"\n    \"expr\": |\n      sum(namespace_name:kube_pod_container_resource_requests_cpu_cores:sum)\n
    \       /\n      sum(node:node_num_cpu:sum)\n        >\n      (count(node:node_num_cpu:sum)-1)
    / count(node:node_num_cpu:sum)\n    \"for\": \"5m\"\n    \"labels\": \n      \"severity\":
    \"warning\"\n  - \"alert\": \"KubeMemOvercommit\"\n    \"annotations\": \n      \"message\":
    \"Overcommited Memory resource requests on Pods, cannot tolerate node failure.\"\n
    \   \"expr\": |\n      sum(namespace_name:kube_pod_container_resource_requests_memory_bytes:sum)\n
    \       /\n      sum(node_memory_MemTotal)\n        >\n      (count(node:node_num_cpu:sum)-1)\n
    \       /\n      count(node:node_num_cpu:sum)\n    \"for\": \"5m\"\n    \"labels\":
    \n      \"severity\": \"warning\"\n  - \"alert\": \"KubeCPUOvercommit\"\n    \"annotations\":
    \n      \"message\": \"Overcommited CPU resource request quota on Namespaces.\"\n
    \   \"expr\": |\n      sum(kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\",
    resource=\"requests.cpu\"})\n        /\n      sum(node:node_num_cpu:sum)\n        >
    1.5\n    \"for\": \"5m\"\n    \"labels\": \n      \"severity\": \"warning\"\n
    \ - \"alert\": \"KubeMemOvercommit\"\n    \"annotations\": \n      \"message\":
    \"Overcommited Memory resource request quota on Namespaces.\"\n    \"expr\": |\n
    \     sum(kube_resourcequota{job=\"kube-state-metrics\", type=\"hard\", resource=\"requests.memory\"})\n
    \       /\n      sum(node_memory_MemTotal{job=\"node-exporter\"})\n        > 1.5\n
    \   \"for\": \"5m\"\n    \"labels\": \n      \"severity\": \"warning\"\n  - \"alert\":
    \"KubeQuotaExceeded\"\n    \"annotations\": \n      \"message\": \"{{ printf \\\"%0.0f\\\"
    $value }}% usage of {{ $labels.resource }} in namespace {{ $labels.namespace }}.\"\n
    \   \"expr\": |\n      100 * kube_resourcequota{job=\"kube-state-metrics\", type=\"used\"}\n
    \       / ignoring(instance, job, type)\n      kube_resourcequota{job=\"kube-state-metrics\",
    type=\"hard\"}\n        > 90\n    \"for\": \"15m\"\n    \"labels\": \n      \"severity\":
    \"warning\"\n- \"name\": \"kubernetes-storage\"\n  \"rules\": \n  - \"alert\":
    \"KubePersistentVolumeUsageCritical\"\n    \"annotations\": \n      \"message\":
    \"The persistent volume claimed by {{ $labels.persistentvolumeclaim }} in namespace
    {{ $labels.namespace }} has {{ printf \\\"%0.0f\\\" $value }}% free.\"\n    \"expr\":
    |\n      100 * kubelet_volume_stats_available_bytes{job=\"kubelet\"}\n        /\n
    \     kubelet_volume_stats_capacity_bytes{job=\"kubelet\"}\n        < 3\n    \"for\":
    \"1m\"\n    \"labels\": \n      \"severity\": \"critical\"\n  - \"alert\": \"KubePersistentVolumeFullInFourDays\"\n
    \   \"annotations\": \n      \"message\": \"Based on recent sampling, the persistent
    volume claimed by {{ $labels.persistentvolumeclaim }} in namespace {{ $labels.namespace
    }} is expected to fill up within four days.\"\n    \"expr\": |\n      predict_linear(kubelet_volume_stats_available_bytes{job=\"kubelet\"}[1h],
    4 * 24 * 3600) < 0\n    \"for\": \"5m\"\n    \"labels\": \n      \"severity\":
    \"critical\"\n- \"name\": \"kubernetes-system\"\n  \"rules\": \n  - \"alert\":
    \"KubeNodeNotReady\"\n    \"annotations\": \n      \"message\": \"{{ $labels.node
    }} has been unready for more than an hour\"\n    \"expr\": |\n      max(kube_node_status_ready{job=\"kube-state-metrics\",
    condition=\"false\"} == 1) BY (node)\n    \"for\": \"1h\"\n    \"labels\": \n
    \     \"severity\": \"warning\"\n  - \"alert\": \"KubeVersionMismatch\"\n    \"annotations\":
    \n      \"message\": \"There are {{ $value }} different versions of Kubernetes
    components running.\"\n    \"expr\": |\n      count(count(kubernetes_build_info{job!=\"kube-dns\"})
    by (gitVersion)) > 1\n    \"for\": \"1h\"\n    \"labels\": \n      \"severity\":
    \"warning\"\n  - \"alert\": \"KubeClientErrors\"\n    \"annotations\": \n      \"message\":
    \"Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing
    {{ printf \\\"%0.0f\\\" $value }}% errors.'\"\n    \"expr\": |\n      sum(rate(rest_client_requests_total{code!~\"2..\"}[5m]))
    by (instance, job) * 100\n        /\n      sum(rate(rest_client_requests_total[5m]))
    by (instance, job)\n        > 1\n    \"for\": \"15m\"\n    \"labels\": \n      \"severity\":
    \"warning\"\n  - \"alert\": \"KubeClientErrors\"\n    \"annotations\": \n      \"message\":
    \"Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing
    {{ printf \\\"%0.0f\\\" $value }} errors / sec.'\"\n    \"expr\": |\n      sum(rate(ksm_scrape_error_total{job=\"kube-state-metrics\"}[5m]))
    by (instance, job) > 0.1\n    \"for\": \"15m\"\n    \"labels\": \n      \"severity\":
    \"warning\""
kind: ConfigMap
metadata:
  labels:
    prometheus: k8s
    role: alert-rules
  name: prometheus-k8s-rules
  namespace: tooling
---
apiVersion: v1
kind: Service
metadata:
  labels:
    prometheus: k8s
  name: prometheus-k8s
  namespace: tooling
spec:
  ports:
  - name: web
    port: 9090
    targetPort: web
  selector:
    app: prometheus
    prometheus: k8s
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-k8s
  namespace: tooling
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: apiserver
  name: kube-apiserver
  namespace: tooling
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: 30s
    port: https
    scheme: https
    tlsConfig:
      caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      serverName: kubernetes
  jobLabel: component
  namespaceSelector:
    matchNames:
    - default
  selector:
    matchLabels:
      component: apiserver
      provider: kubernetes
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: coredns
  name: coredns
  namespace: tooling
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: 15s
    port: http-metrics
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - kube-system
  selector:
    matchLabels:
      component: metrics
      k8s-app: coredns
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: kube-controller-manager
  name: kube-controller-manager
  namespace: tooling
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - kube-system
  selector:
    matchLabels:
      k8s-app: kube-controller-manager
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: kube-scheduler
  name: kube-scheduler
  namespace: tooling
spec:
  endpoints:
  - interval: 30s
    port: http-metrics
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - kube-system
  selector:
    matchLabels:
      k8s-app: kube-scheduler
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: kubelet
  name: kubelet
  namespace: tooling
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: 30s
    port: https-metrics
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    honorLabels: true
    interval: 30s
    path: /metrics/cadvisor
    port: https-metrics
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - kube-system
  selector:
    matchLabels:
      k8s-app: kubelet
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: prometheus
  name: prometheus
  namespace: tooling
spec:
  endpoints:
  - interval: 30s
    port: web
  namespaceSelector:
    matchNames:
    - tooling
  selector:
    matchLabels:
      prometheus: k8s
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: prometheus-operator
  name: prometheus-operator
  namespace: tooling
spec:
  endpoints:
  - port: http
  selector:
    matchLabels:
      k8s-app: prometheus-operator


COINCOIN