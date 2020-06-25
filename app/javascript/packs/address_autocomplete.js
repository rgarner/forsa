require('./jquery.autoaddress.js')

/*
  From a given textarea, insert a div.auto-address-root before it
  and call the autoaddress setup on that root.

  Looks for a data-type attr which is passed to autoaddress configuration.
 */
class AddressAutocomplete {
  constructor(textarea) {
    this.textarea = textarea
  }

  manualLinkClicked() {
    this.textarea.style.display = 'block'
    this.manualLink.style.display = 'none'
    this.textarea.focus()
  }

  get manualLink() {
    if(this._manualLink) {
      return this._manualLink
    }

    const _manualLink = document.createElement('a')
    const textNode = document.createTextNode('Or enter address manually');
    _manualLink.appendChild(textNode)
    _manualLink.addEventListener('click', this.manualLinkClicked.bind(this))

    this._manualLink = _manualLink
    return _manualLink
  }


  get input() {
    if(!this._input) {
      this._input = $(this.autoAddressRoot).find('input')
    }

    return this._input
  }

  get countryRadioGroup() {
    if(this._countryRadioGroup) {
      return this._countryRadioGroup
    }

    const radioStr = `
      <fieldset class="radio-group-vertical">
        <div>
          <label for="country_ireland">
            <input type="radio" value="ie" name="country" id="country_ireland" checked="checked">
            Ireland
          </label>
          <label for="country_ni">
            <input type="radio" value="ni" name="country" id="country_ni">
            Northern Ireland
          </label>
        </div>  
      </fieldset>    
    `

    const dom = new DOMParser().parseFromString(radioStr, 'text/html')
    this._countryRadioGroup = dom.body.firstElementChild;
    return this._countryRadioGroup;
  }

  countryChanged() {
    $(this.autoAddressRoot).AutoAddress('setCountry', this.countryValue)
  }

  get countryValue() {
    return $(this.countryRadioGroup).find('input[name=country]:checked').val();
  }

  get autoAddressRoot() {
    if(this._autoAddressRoot) {
      return this._autoAddressRoot
    }

    const root = document.createElement('div');
    root.setAttribute('class', 'auto-address-root')

    this.textarea.parentNode.insertBefore(root, this.textarea);
    this.textarea.parentNode.insertBefore(this.manualLink, this.textarea);
    this.textarea.parentNode.insertBefore(this.countryRadioGroup, root);

    $(this.countryRadioGroup).find('input').change(() => this.countryChanged())

    this._autoAddressRoot = root
    return root
  }

  attachAutoAddressAutocomplete() {
    $(this.autoAddressRoot).AutoAddress({
      key: process.env.AUTOADDRESS_KEY,
      vanityMode: true,
      addressProfile: "Demo5LineV2",
      country: 'ie',
      optionsLimit: -1,

      onSearchCompleted: (data) => this.placeChanged(data),
    })

    this.setVisibilitiesFromValue();
  }

  // Show/hide bits based on whether we have a value
  setVisibilitiesFromValue() {
    if (this.textarea.value) {
      this.textarea.style.display = 'block'
      this.manualLink.style.display = 'none'
    } else { // Only hide when the value is blank so as not to hide real data
      this.textarea.style.display = 'none'
      this.manualLink.style.display = 'block'
    }
  }

  placeChanged(data) {
    const addressWithPostcode = data.vanityAddress.concat(data.postcode)
    this.textarea.value = addressWithPostcode.join("\r\n")
    this.input.value = null
    this.setVisibilitiesFromValue()
    this.textarea.focus()
  }

  static create(textarea) {
    let autocomplete = new AddressAutocomplete(textarea)
    autocomplete.attachAutoAddressAutocomplete()
  }

  static setup() {
    document.querySelectorAll('.address-autocomplete')
      .forEach(element => AddressAutocomplete.create(element))
  }
}

export { AddressAutocomplete }
