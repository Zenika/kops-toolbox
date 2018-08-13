gcloud projects create $GCLOUD_PROJECT_ID

gcloud config set project $GCLOUD_PROJECT_ID
gcloud iam service-accounts create $GCLOUD_PROJECT_ID
gcloud projects add-iam-policy-binding [$GCLOUD_PROJECT_ID] --member "serviceAccount:[$GCLOUD_SERVICE_ACCOUNT]@[$GCLOUD_PROJECT_ID].iam.gserviceaccount.com" --role "roles/owner"
