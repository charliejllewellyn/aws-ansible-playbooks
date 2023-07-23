for run in {1..10}; do
  productName=k8-$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
  echo $productName
  aws servicecatalog provision-product --product-id prod-atlpq6fmtowqc --provisioning-artifact-id pa-n5rtuy5zhduaa --provisioned-product-name $productName &>/dev/null
  
  while aws servicecatalog describe-provisioned-product --name $productName | jq .ProvisionedProductDetail.Status -r | grep UNDER_CHANGE &>/dev/null; do
    sleep 10
  done
  
  status=$(aws servicecatalog describe-provisioned-product --name $productName | jq .ProvisionedProductDetail.Status -r)

  echo $status
  
  if [[ "$status" == "AVAILABLE" ]]; then
    s3Bucket=$(aws servicecatalog get-provisioned-product-outputs --provisioned-product-name $productName | jq .Outputs[1].OutputValue -r)
  
    aws servicecatalog terminate-provisioned-product --provisioned-product-name $productName &>/dev/null
    aws s3 rm s3://$s3Bucket --recursive &>/dev/null
    aws s3api delete-bucket --bucket $s3Bucket
  fi
done
