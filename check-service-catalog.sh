for run in {1..10}; do
  productName=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
  aws servicecatalog provision-product --product-id prod-atlpq6fmtowqc --provisioning-artifact-id pa-y2aq32ikehjvu --provisioned-product-name $productName &>/dev/null
  
  while aws servicecatalog describe-provisioned-product --name $productName | jq .ProvisionedProductDetail.Status -r | grep UNDER_CHANGE &>/dev/null; do
  sleep 10
  done
  
  aws servicecatalog describe-provisioned-product --name $productName | jq .ProvisionedProductDetail.Status -r
  
  aws servicecatalog terminate-provisioned-product --provisioned-product-name $productName
done
