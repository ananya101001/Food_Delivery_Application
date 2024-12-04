# Create the API Gateway
resource "aws_api_gateway_rest_api" "food_delivery_api" {
  name        = "food-delivery-api"
  description = "API Gateway for the Food Delivery Application"
}

# Create resources in the API Gateway
resource "aws_api_gateway_resource" "restaurants" {
  rest_api_id = aws_api_gateway_rest_api.food_delivery_api.id
  parent_id   = aws_api_gateway_rest_api.food_delivery_api.root_resource_id
  path_part   = "restaurants"
}

# Define HTTP methods for the restaurants resource
resource "aws_api_gateway_method" "get_restaurants" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.restaurants.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_restaurant" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.restaurants.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate the API Gateway with Lambda functions
resource "aws_api_gateway_integration" "get_restaurants_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.restaurants.id
  http_method             = aws_api_gateway_method.get_restaurants.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_restaurants.invoke_arn
}

resource "aws_api_gateway_integration" "post_restaurant_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.restaurants.id
  http_method             = aws_api_gateway_method.post_restaurant.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_restaurant.invoke_arn
}

# Create menu resource
resource "aws_api_gateway_resource" "menu" {
  rest_api_id = aws_api_gateway_rest_api.food_delivery_api.id
  parent_id   = aws_api_gateway_rest_api.food_delivery_api.root_resource_id
  path_part   = "menu"
}

# Define GET method for menu
resource "aws_api_gateway_method" "get_menu" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.menu.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_menu" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.menu.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate GET menu with Lambda function
resource "aws_api_gateway_integration" "get_menu_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.menu.id
  http_method             = aws_api_gateway_method.get_menu.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_menu.invoke_arn
}

resource "aws_api_gateway_integration" "post_menu_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.menu.id
  http_method             = aws_api_gateway_method.post_menu.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_menu.invoke_arn
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.food_delivery_api.id
  parent_id   = aws_api_gateway_rest_api.food_delivery_api.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_method" "post_order" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_order" {
  rest_api_id   = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.orders.id
  http_method             = aws_api_gateway_method.post_order.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_order.invoke_arn
}

resource "aws_api_gateway_integration" "get_order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.food_delivery_api.id
  resource_id             = aws_api_gateway_resource.orders.id
  http_method             = aws_api_gateway_method.get_order.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_order.invoke_arn
}

# Update the deployment to include the new menu resource
resource "aws_api_gateway_deployment" "food_delivery_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_restaurants_integration,
    aws_api_gateway_integration.post_restaurant_integration,
    aws_api_gateway_integration.get_menu_integration,
    aws_api_gateway_integration.post_menu_integration,
    aws_api_gateway_integration.post_order_integration,
    aws_api_gateway_integration.get_order_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.food_delivery_api.id
  stage_name  = "prod"
}


# Lambda permission for API Gateway to invoke get_menu function
resource "aws_lambda_permission" "api_gateway_lambda_get_restaurants" {
  statement_id  = "AllowAPIGatewayInvokeGetRestaurants"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_restaurants.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/GET/restaurants"
}

resource "aws_lambda_permission" "api_gateway_lambda_post_restaurant" {
  statement_id  = "AllowAPIGatewayInvokePostRestaurant"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_restaurant.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/POST/restaurants"
}

resource "aws_lambda_permission" "api_gateway_lambda_get_menu" {
  statement_id  = "AllowAPIGatewayInvokeMenu"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_menu.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/GET/menu"
}
resource "aws_lambda_permission" "api_gateway_lambda_post_menu" {
  statement_id  = "AllowAPIGatewayInvokePostMenu"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_menu.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/POST/menu"
}

resource "aws_lambda_permission" "api_gateway_lambda_post_order" {
  statement_id  = "AllowAPIGatewayInvokePostOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/POST/orders"
}

resource "aws_lambda_permission" "api_gateway_lambda_get_order" {
  statement_id  = "AllowAPIGatewayInvokeGetOrder"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_order.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.food_delivery_api.execution_arn}/*/GET/orders"
}



# Additional output for menu endpoint
output "api_endpoint" {
  value = "${aws_api_gateway_deployment.food_delivery_deployment.invoke_url}/restaurants"
}

output "menu_api_endpoint" {
  value = "${aws_api_gateway_deployment.food_delivery_deployment.invoke_url}/menu"
}

output "orders_api_endpoint" {
  value = "${aws_api_gateway_deployment.food_delivery_deployment.invoke_url}/orders"
}
