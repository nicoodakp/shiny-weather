library(httr)
library(jsonlite)
library(xml2)
library(dplyr)
library(tidyr)
library(lubridate)
library(shiny)
library(rsconnect)


ui <- fluidPage(
  
  tags$script('
      $(document).ready(function () {
              navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }
              
              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("lat:", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
              }, 1100)
              }
              });
              '),
    mainPanel(htmlOutput("weather"))
)


server <- function(input, output, session){

vals <- reactiveValues()
  observe({
    vals$lat <- input$lat
    vals$long <- input$long
    vals$geo <- input$geolocation
  
    # src = "https://forecast.io/embed/#lat=42.3583&lon=-71.0603&name=Downtown Boston"
  
          })  ## wraps up observe line-39     

output$weather <- renderUI({
   base     <- "https://maps.googleapis.com/maps/api/geocode/"
   api_key  <- "AIzaSyBUySixqWTvfvEa6e0o_EZ_AVKkdNkRUzU"
   geo  <- paste(vals$lat,vals$long,sep=",")
   call.add <- paste(base, "json?", "latlng=", geo, "&key=", api_key, sep = "")
   address <- GET(call.add, encode = c('json'))
   address_content <- content(address, as = "text", encoding = "UTF-8")
   json_content <- address_content %>%  fromJSON
   add <- json_content$results$formatted_address[3]
   dark.base1 <- "https://forecast.io/embed/#"
   call.dark1 <- paste(dark.base1, "lat=", vals$lat, "&lon=", vals$long, "&name=", add, sep="")
   tags$iframe(src=call.dark1, height=250, width=1800, frameborder = 0)
})  ## renderUI

                                              } ## server Function

##  create app
shinyApp(ui = ui, server = server)

# # deploy to shiny.io
# rsconnect::setAccountInfo(name='kai-peng', token='7AAA6ADAA4CE6E79D0117E5AB66947F1', secret='')
# library(rsconnect)
# rsconnect::deployApp('C:/Users/nicoo/OneDrive/eng/weather')