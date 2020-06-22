const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
const dotenv = require('dotenv')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery'
  })
)

dotenv.config({ path: '.env', silent: true })
environment.plugins.insert(
  "Environment",
  new webpack.EnvironmentPlugin(process.env)
)

module.exports = environment
