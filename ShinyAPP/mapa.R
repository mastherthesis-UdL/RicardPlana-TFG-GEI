server <- function(input, output) {
    abs <- readOGR("ABS_2018/RegionsS_2018.shp",
                    layer = "RegionsS_2018", GDAL1_integer64_policy = TRUE, use_iconv=TRUE, encoding="UTF-8")

    output$plot_abs <- renderLeaflet({
        leaflet(abs) %>%
        setView(lng = 1.3984735784516196, lat = 42.091848475624886, zoom = 8) %>%
        addTiles() %>%
        #addProviderTiles(providers$Esri.WorldTopoMap) %>%
        addPolygons(color = "#FF0000", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    fillColor = ~colorQuantile("YlOrRd", NA.)(NA.),
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE))
    })
  
}



#leafletOutput("plot_abs")