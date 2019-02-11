# config/initializers/swagger_ui_engine.rb

SwaggerUiEngine.configure do |config|
  config.swagger_url = {
    "v0_0_1": '/service_portal/v0.0.1/openapi.json',
    "v0_1_0": '/service_portal/v0.1.0/openapi.json',
  }
end
