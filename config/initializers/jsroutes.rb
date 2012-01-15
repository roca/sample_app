unless Rails.env == 'production'
  JsRoutes.generate!({
   # options
  })
end