library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(geojsonio)
library(jsonlite)
library(DT)
library(ggplot2)
library(reshape2)
library(plyr)
library(tidyverse)
library(ggpol)
require(RColorBrewer)
library(httr)
library(htmltools)
library(rgdal)
library(plotly)
library(shinyjs)
#library(rjson)
library(xlsx)
library(raster)

# Funció per imprimer una piràmide poblacional 
# @df = dataframe amb tres columnes Edat,Valor i Sexe

getSexeCount <- function(sexeValue){

  paramsJson = paste('{"filters" : {"SexeCount": [',sexeValue,']}}')
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  sexeCount <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(sexeCount)

  return(result)
}

getTotalReceipt <- function(medValue){
  paramsJson = paste('{"filters" : {"totalReceipt": ["',medValue,'"]}}', sep = "")
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  getTotalReceiptJson <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(getTotalReceiptJson)
  print(result)
  return(result)
}
#result$sumPacient, result$sumLIQ, result$sumRec
plotPyramide <- function(){ 
    
  countHomes <- getSexeCount(0)
  countDones <- getSexeCount(1)
  total <- data.frame()

  ##MALE
  #0-9
  age1 = 0
  #10-19
  age2 = 0
  #20-29
  age3 = 0
  #30-39
  age4 = 0
  #40-49
  age5 = 0
  #50-59
  age6 = 0
  #60-69
  age7 = 0
  #70-79
  age8 = 0
  #+80
  age9 = 0

  for(i in 1:nrow(countHomes)){

    if(countHomes[i,1] >= 0 && countHomes[i,1] <=9){
      age1 = age1 + countHomes[i,2]
    }   
    else if(countHomes[i,1] >= 10 && countHomes[i,1] <=19){
      age2 = age2 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 20 && countHomes[i,1] <=29){
      age3 = age3 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 30 && countHomes[i,1] <=39){
      age4 = age4 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 40 && countHomes[i,1] <=49){
      age5 = age5 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 50 && countHomes[i,1] <=59){
      age6 = age6 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 60 && countHomes[i,1] <=69){
      age7 = age7 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 70 && countHomes[i,1] <=79){
      age8 = age8 + countHomes[i,2]
    }
    else if(countHomes[i,1] >= 80){
      age9 = age9 + countHomes[i,2]
    }
  }

  value <- data.frame(Age= "0-9", Gender="Male", Population = age1)
  total <-rbind(total, value)

  value <- data.frame(Age= "10-19", Gender="Male", Population = age2)
  total <-rbind(total, value)

  value <- data.frame(Age= "20-29", Gender="Male", Population = age3)
  total <-rbind(total, value)

  value <- data.frame(Age= "30-39", Gender="Male", Population = age4)
  total <-rbind(total, value)

  value <- data.frame(Age= "40-49", Gender="Male", Population = age5)
  total <-rbind(total, value)

  value <- data.frame(Age= "50-59", Gender="Male", Population = age6)
  total <-rbind(total, value)

  value <- data.frame(Age= "60-69", Gender="Male", Population = age7)
  total <-rbind(total, value)

  value <- data.frame(Age= "70-79", Gender="Male", Population = age8)
  total <-rbind(total, value)

  value <- data.frame(Age= "80+", Gender="Male", Population = age9)
  total <-rbind(total, value)

  ##FEMALE
  #0-9
  age1 = 0
  #10-19
  age2 = 0
  #20-29
  age3 = 0
  #30-39
  age4 = 0
  #40-49
  age5 = 0
  #50-59
  age6 = 0
  #60-69
  age7 = 0
  #70-79
  age8 = 0
  #+80
  age9 = 0

  for(i in 1:nrow(countDones)){

    if(countDones[i,1] >= 0 && countDones[i,1] <=9){
      age1 = age1 + countDones[i,2]
    }   
    else if(countDones[i,1] >= 10 && countDones[i,1] <=19){
      age2 = age2 + countDones[i,2]
    }
    else if(countDones[i,1] >= 20 && countDones[i,1] <=29){
      age3 = age3 + countDones[i,2]
    }
    else if(countDones[i,1] >= 30 && countDones[i,1] <=39){
      age4 = age4 + countDones[i,2]
    }
    else if(countDones[i,1] >= 40 && countDones[i,1] <=49){
      age5 = age5 + countDones[i,2]
    }
    else if(countDones[i,1] >= 50 && countDones[i,1] <=59){
      age6 = age6 + countDones[i,2]
    }
    else if(countDones[i,1] >= 60 && countDones[i,1] <=69){
      age7 = age7 + countDones[i,2]
    }
    else if(countDones[i,1] >= 70 && countDones[i,1] <=79){
      age8 = age8 + countDones[i,2]
    }
    else if(countDones[i,1] >= 80){
      age9 = age9 + countDones[i,2]
    }
  }

  value <- data.frame(Age= "0-9", Gender="Female", Population = age1)
  total <-rbind(total, value)

  value <- data.frame(Age= "10-19", Gender="Female", Population = age2)
  total <-rbind(total, value)

  value <- data.frame(Age= "20-29", Gender="Female", Population = age3)
  total <-rbind(total, value)

  value <- data.frame(Age= "30-39", Gender="Female", Population = age4)
  total <-rbind(total, value)

  value <- data.frame(Age= "40-49", Gender="Female", Population = age5)
  total <-rbind(total, value)

  value <- data.frame(Age= "50-59", Gender="Female", Population = age6)
  total <-rbind(total, value)

  value <- data.frame(Age= "60-69", Gender="Female", Population = age7)
  total <-rbind(total, value)

  value <- data.frame(Age= "70-79", Gender="Female", Population = age8)
  total <-rbind(total, value)

  value <- data.frame(Age= "80+", Gender="Female", Population = age9)
  total <-rbind(total, value)

  p <- ggplot(total, aes(x = Age, y = Population, fill = Gender)) + 
  geom_bar(data = subset(total, Gender == "Female"), stat = "identity") + 
  geom_bar(data = subset(total, Gender == "Male"), stat = "identity", aes(y=Population*(-1))) + 
  scale_y_continuous(breaks=seq(-20000,20000,5000),labels=abs(seq(-20000,20000,5000))) + 
  coord_flip()

   #p <- p + theme(text = element_text(size = 16))
    
  return(p)
}

roundUpNice <- function(x, nice=c(1,2,4,5,6,8,10)) {
    if(length(x) != 1) stop("'x' must be of length 1")
    10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

plotRecep <- function(drugCode){ 
    
  totalReceiptValues <- getTotalReceipt(drugCode)

  total <- data.frame()

  for(i in 1:nrow(totalReceiptValues)){
      value <- data.frame(Mes= totalReceiptValues[i,1], Total=totalReceiptValues[i,2])
      total <-rbind(total, value)
  }

  maxValue <- max(total$Total)
  partialValue <- roundUpNice(maxValue/10)

  p <- ggplot(total, aes(x = Mes, y = Total)) + 
  geom_bar(data = subset(total), stat = "identity", fill = "#48B799") + 
  scale_y_continuous(
                      breaks=seq(0,maxValue,partialValue),
                      #breaks = c(min(total$Total), 0, max(df$x),
                      labels=abs(seq(0,maxValue,partialValue))
                    )
  

  return(p)
}

plotLineRecep <- function(drugCode){ 
    
  totalReceiptValues <- getTotalReceipt(drugCode)

  total <- data.frame()

  for(i in 1:nrow(totalReceiptValues)){
      value <- data.frame(Mes= totalReceiptValues[i,1], Total=totalReceiptValues[i,2])
      total <-rbind(total, value)
  }

  maxValue <- max(total$Total)
  partialValue <- roundUpNice(maxValue/10)

  #p <- ggplot(total, aes(x = Mes, y = Total, fill = Mes)) + 
  p <- ggplot(total, aes(x = Mes, y = Total,  group = 1)) + 
  geom_line()+
  geom_point()

  return(p)
}

getTotalOfArrayList <- function(listNumeric) {
  total = 0
  for (element in listNumeric) {
    total = total + element
  }
  return(total)
}


# Funció per fer un degradat de colors al mapa utilitzant la variable incidencia
getColor <- function(nom, list_comarques_consum, list_comarques_poblacio) {
  out <- tryCatch(
    {
      result = 0
      poblacio = list_comarques_poblacio[[nom]]
      consum = list_comarques_consum[[nom]]
      result = consum/poblacio*10000
      if (result >= 0 && result < 50) {return('#FEF9EA')}
      else if (result >= 50 && result < 100) {return('#FFEDA0')}
      else if (result >= 100 && result < 150) {return('#FEB24C')}
      else if (result >= 150 && result < 200) {return('#FC4E2A')}
      return("#BD0026")
    },
    error=function(cond) {
      return("#FEF9EA")
    }
  )
}


getTotalPatients <- function(sexeValue){

  paramsJson = paste('{"filters" : {"Sexe": [',sexeValue,']}}')
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  totalMalesJson <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(totalMalesJson)

  return(result)
}

getTotals <-function()
{
  paramsJson = paste('{"filters" : {"totalsCount": []}}')
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  totalMalesJson <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(totalMalesJson)
  list <- list((result$sumPacient/1000000), (result$sumLIQ/1000000), (result$sumRec/1000000))

  return(list)
}

getAvgAge <-function()
{
  paramsJson = paste('{"filters" : {"avgAge": []}}')
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  totalMalesJson <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(totalMalesJson)
  list <- list(result$avgEdad)

  return(list)
}

getMedicament <-function(drugCode)
{
  paramsJson = paste('{"filters" : {"Codi_Medicament": ["',drugCode,'"]}}', sep = "")
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  medJson <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(medJson)
  list <- list(result$Codi_Medicament, result$Nom_Medicament, result$PVP, result$GT, result$Any, result$Codi_ATC5, result$Nom_ATC5, result$Codi_ATC7
              , result$Nom_ATC7, result$"Numero_Principi_Actiu(PA)",result$Codi_PA, result$Nom_PA, result$Quantitat_PA, result$Unitats, result$DDD
              , result$DDD_msc, result$Numero_DDD_msc, result$Numero_DDD_calculat
              , result$Unitats_DDD)

  return(list)
}

getMapInformation <- function(codi_medicament) {
  paramsJson = paste('{"filters" : {"countByComarca": ["',codi_medicament,'"]}}', sep = "")
  headers = c('Content-Type' = 'application/json; charset=UTF-8')
  request <- httr::POST(url='http://192.168.101.98:3000/tractaments', httr::add_headers(.headers=headers), body=paramsJson)
  
  comarcaCount <- content(request, "text", encoding = "UTF-8")
  result <- fromJSON(comarcaCount)

  return(result)
}

comarques_habitants <- function(list_comarques_poblacio) {
  list_comarques_poblacio['Alt urgell'] <- 20428
  list_comarques_poblacio['Alta Ribagorça'] <- 3859
  list_comarques_poblacio['Garrigues'] <- 19121
  list_comarques_poblacio['Urgell'] <- 35821
  list_comarques_poblacio['Segrià'] <- 204603
  list_comarques_poblacio["Pla d'Urgell"] <- 36751
  list_comarques_poblacio["Val d'aran"] <- 9776
  list_comarques_poblacio['Segarra'] <- 22532
  list_comarques_poblacio['Pallars Sobirà'] <- 6908
  list_comarques_poblacio['Pallars Jussà'] <- 13182
  list_comarques_poblacio['Noguera'] <- 38472
  return(list_comarques_poblacio)
}

# Menu
sidebar <- dashboardSidebar(
    sidebarMenu(
        tags$head(tags$style(HTML('.content-wrapper { height: 1800px !important;}'))),
        menuItem("Menu Principal", tabName = "resum", icon = icon("dashboard")),
        menuItem("Mapa GeoJson", tabName = "mapa", icon = icon("map"))
    )
)

listCounts <- getTotals()
numMales <- getTotalPatients(0)
numWomens <- getTotalPatients(1)
avgAge <- getAvgAge()
roundedAVG <- round(as.double(avgAge[1]), digits=0)



url <- ("http://kenpom.com/team.php?team=Rice")
# Cos del Dashboard amb les seve parts
body <- dashboardBody(
    tabItems(
            tabItem(tabName = "resum",
                    h2("Resum dades analitzades"),
                    fluidRow(
                      # A static valueBox
                      valueBox(numMales, "Total homes", icon = icon("male"), color = "aqua"),
                      valueBox(numWomens, "Total dones", icon = icon("female"), color = "blue"),
                      valueBox(roundedAVG, "Mitja Edat", icon = icon("users"), color = "light-blue"),
                      valueBox(paste(toString(round(as.double(listCounts[3]), digits=2)),' M'), "Total Receptes", icon = icon("meds"), color = "teal"),
                      valueBox(paste(toString(round(as.double(listCounts[1]), digits=2)),' M'), "Aportació total pacient", icon = icon("euro"), color = "olive"),
                      valueBox(paste(toString(round(as.double(listCounts[2]), digits=2)),' M'), "Aportació total CATSalut", icon = icon("euro"), color = "purple")
                    ),
                    box(
                        title = "Taula de medicaments",
                        status = "info",
                        textInput("caption", "Codi Medicament"),
                        tableOutput("obs"),
                        style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
                        
                    ),
                    box(
                        title = "Gràfica de la distribució",
                        status = "info",
                        plotOutput(outputId = "distribution_plot", height = 500),
                        style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
                    ),
                    box(
                        title = "BarPlot Nº Receptes",
                        status = "info",
                        width =12,
                        #plotOutput(outputId = "recep_plot", height = 500)
                        plotlyOutput(outputId = "recep_plot", height = 500)
                    ),  
                    box(
                        title = "LinePlot Nº Receptes",
                        status = "info",
                        width =12,
                        #plotOutput(outputId = "recep_plot", height = 500)
                        plotlyOutput(outputId = "recepLine_plot", height = 500)
                    ) 
                            
            ),
            tabItem(tabName = "mapa",
                h2("Mapa ABS-GeoJson"),
                textInput("medComarca", "Codi Medicament"), 
                leafletOutput("map")           
            )
    )
)


ui <- dashboardPage(
    dashboardHeader(
        title = "Registre del càncer a la provincia de Lleida",
        titleWidth = 600
    ),
    sidebar,body)
        
      
server <- function(input, output, session) {    
    #
    
    ########### Secció Inicial - Dashboard
    ##MAPA
    #Inicialitza les llistes de consum i de poblacio total per comarca
  list_comarques_consum <- vector(mode="list", length=11)
  names(list_comarques_consum) <- c('Urgell', 'Segrià', "Pla d'Urgell", "Val d'aran", "Segarra",
                                    "Pallars Sobirà", "Pallars Jussà", "Noguera", "Alt urgell",
                                    "Garrigues", "Alta Ribagorça")
  
  list_comarques_poblacio <- vector(mode="list", length=11)
  names(list_comarques_poblacio) <- c('Urgell', 'Segrià', "Pla d'Urgell", "Val d'aran", "Segarra",
                                      "Pallars Sobirà", "Pallars Jussà", "Noguera", "Alt urgell",
                                      "Garrigues", "Alta Ribagorça")
  
  result <- getMapInformation("663680") #Aqui va el codi medicament que l'usuari seleccioni
  
  # Parsejar el resultat de la peticio i ho afegeix a la llista de consum.
  for(i in 1:nrow(result)) {       # for-loop over rows
    comarca <- result[i, 1]
    value <- result[i, 2]
    list_comarques_consum[comarca] <- value
  }
  
  # Crear la llista de poblacio per comarca amb les dades
  list_comarques_poblacio <- comarques_habitants(list_comarques_poblacio)
  
  
  geojson <- readLines("../maps/lleida.geojson", warn = FALSE) %>%
    paste(collapse = "\n") %>%
    fromJSON(simplifyVector = FALSE)
  
  # Default styles for all features
  geojson$style = list(
    weight = 1,
    color = "#555555",
    opacity = 1,
    fillOpacity = 0.8
  )
  
  geojson$features <- lapply(geojson$features, function(feat) {
    feat$properties$style <- list(
        fillColor = getColor(feat$properties$nom_comar, list_comarques_consum, list_comarques_poblacio)
      )
    feat
  })

  output$map <- renderLeaflet({
    leaflet() %>% addGeoJSON(geojson) %>%
      addLegend("bottomright",
                colors =c("#BD0026", "#FC4E2A",  "#FEB24C",  "#FFEDA0", "#FEF9EA"),
                labels= c("+200", "200 - 150","150 - 100", "100 - 50", "0 - 50"),
                title= "Punts de prescripció",
                opacity = 1) %>%
      setView(lat = 41.9505 , lng = 0.8677, zoom = 7)
  })

  

    # Piramide d'Edat
    output$distribution_plot <- renderPlot({
        plotPyramide()
    })
    # Meds Table
    listmeds <- getMedicament("946582")
    setValues <- list(listmeds[1], listmeds[2], listmeds[3], listmeds[4], listmeds[5], listmeds[6], listmeds[7], listmeds[8], listmeds[9]
        , listmeds[10], listmeds[11], listmeds[12], listmeds[13], listmeds[14], listmeds[15], listmeds[16], listmeds[17],listmeds[18],listmeds[19])
    values <- matrix(setValues, ncol = 1)
    colnames(values) <- "Medicament"
    rownames(values) <- c("Codi Medicament", "Nom Medicament", "PVP", "GT", "Any", "Codi_ATC5", "Nom_ATC5", "Codi_ATC7", "Nom_ATC7",
                          "Numero_Principi_Actiu(PA)", "Codi_PA", "Nom_PA", "Quantitat_PA", "Unitats", "DDD", "DDD_msc", "Numero_DDD_msc",
                          "Numero_DDD_calculat", "Unitats_DDD"
                          )
    output$obs <- renderTable({values}, rownames = TRUE)

    #Plotli nº receptes
    output$recep_plot <- renderPlotly({
    plotRecep("946582")
    })

    output$recepLine_plot <- renderPlotly({
    plotLineRecep("946582")
    })
    #Observe Taula medicaments + plotly
    v <- observeEvent(req(input$caption),{ 
    
      listmeds <- getMedicament(input$caption)
      setValues <- list(listmeds[1], listmeds[2], listmeds[3], listmeds[4], listmeds[5], listmeds[6], listmeds[7], listmeds[8], listmeds[9]
                        , listmeds[10], listmeds[11], listmeds[12], listmeds[13], listmeds[14], listmeds[15], listmeds[16], listmeds[17],listmeds[18],listmeds[19])
      values <- matrix(setValues, ncol = 1)
      colnames(values) <- "Medicament"
      rownames(values) <- c("Codi Medicament", "Nom Medicament", "PVP", "GT", "Any", "Codi_ATC5", "Nom_ATC5", "Codi_ATC7", "Nom_ATC7",
                            "Numero_Principi_Actiu(PA)", "Codi_PA", "Nom_PA", "Quantitat_PA", "Unitats", "DDD", "DDD_msc", "Numero_DDD_msc",
                            "Numero_DDD_calculat", "Unitats_DDD"
      )
      output$obs <- renderTable({values}, rownames = TRUE)

      output$recep_plot <- renderPlotly({
        plotRecep(input$caption)
      })

      output$recepLine_plot <- renderPlotly({
        plotLineRecep(input$caption)
      })     
    })
    #Observe map comarca
    v <- observeEvent(req(input$medComarca),{ 
      result <- getMapInformation(input$medComarca) #Aqui va el codi medicament que l'usuari seleccioni
  
      # Parsejar el resultat de la peticio i ho afegeix a la llista de consum.
      for(i in 1:nrow(result)) {       # for-loop over rows
        comarca <- result[i, 1]
        value <- result[i, 2]
        list_comarques_consum[comarca] <- value
      }
      
      # Crear la llista de poblacio per comarca amb les dades
      list_comarques_poblacio <- comarques_habitants(list_comarques_poblacio)
      
      
      geojson <- readLines("../maps/lleida.geojson", warn = FALSE) %>%
        paste(collapse = "\n") %>%
        fromJSON(simplifyVector = FALSE)
      
      # Default styles for all features
      geojson$style = list(
        weight = 1,
        color = "#555555",
        opacity = 1,
        fillOpacity = 0.8
      )
      
      geojson$features <- lapply(geojson$features, function(feat) {
        feat$properties$style <- list(
            fillColor = getColor(feat$properties$nom_comar, list_comarques_consum, list_comarques_poblacio)
          )
        feat
      })

      output$map <- renderLeaflet({
          leaflet() %>% addGeoJSON(geojson) %>%
            addLegend("bottomright",
                      colors =c("#BD0026", "#FC4E2A",  "#FEB24C",  "#FFEDA0", "#FEF9EA"),
                      labels= c("+200", "200 - 150","150 - 100", "100 - 50", "0 - 50"),
                      title= "Punts de prescripció",
                      opacity = 1) %>%
            setView(lat = 41.9505 , lng = 0.8677, zoom = 7)
        })
    })


    
}



options(shiny.autoreload = TRUE)
shinyApp(ui, server)