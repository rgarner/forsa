set -e
export BASE_URL=https://api.autoaddress.ie/2.0/control
curl $BASE_URL/images/close-msg.png > app/assets/images/aa/close-msg.png
curl $BASE_URL/images/success-msg-icon-circle.png > app/assets/images/aa/success-msg-icon-circle.png
curl $BASE_URL/images/alert-msg-icon-circle.png > app/assets/images/aa/alert-msg-icon-circle.png
curl $BASE_URL/images/error-msg-icon-circle.png > app/assets/images/aa/error-msg-icon-circle.png
curl $BASE_URL/images/alert-msg-icon-circle.png > app/assets/images/aa/alert-msg-icon-circle.png
curl $BASE_URL/images/auto-search-icon.png > app/assets/images/aa/auto-search-icon.png
curl $BASE_URL/images/auto-search-icon-hover.png > app/assets/images/aa/auto-search-icon-hover.png
curl $BASE_URL/images/multi-address-arrow.png > app/assets/images/aa/multi-address-arrow.png
curl $BASE_URL/images/multi-address-arrow-select.png > app/assets/images/aa/multi-address-arrow-select.png
curl $BASE_URL/images/MultiAddress-List.png > app/assets/images/aa/MultiAddress-List.png
curl $BASE_URL/images/MultiAddress-List-select.png > app/assets/images/aa/MultiAddress-List-select.png
curl $BASE_URL/images/address-tab.png > app/assets/images/aa/address-tab.png
curl $BASE_URL/images/address-tab-selected.png > app/assets/images/aa/address-tab-selected.png
curl $BASE_URL/images/Commercial-tab.png > app/assets/images/aa/Commercial-tab.png
curl $BASE_URL/images/Commercial-tab-selected.png > app/assets/images/aa/Commercial-tab-selected.png
curl $BASE_URL/images/back.png > app/assets/images/aa/back.png
