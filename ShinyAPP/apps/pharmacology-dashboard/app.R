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

  p <- ggplot(total, aes(x = Mes, y = Total, fill = Mes)) + 
  geom_bar(data = subset(total), stat = "identity") + 
  scale_y_continuous(
                      breaks=seq(0,maxValue,partialValue),
                      #breaks = c(min(total$Total), 0, max(df$x),
                      labels=abs(seq(0,maxValue,partialValue))
                    )
    
  return(p)
}
getTotalOfArrayList <- function(listNumeric) {
  total = 0
  for (element in listNumeric) {
    total = total + element
  }
  return(total)
}

# Funció per obtenir tots el tipus de cancer que analitzarem
cancerTypes <- function(){
    v <- factor(c("Pulmó", "Mama", "Còlon", "Recte", "Pròstata","Bufeta","Mieloma", "Estómac","Endometri","Pell","Ossos"))
    return(v)
}

# Funció per mostrar el mapa
printMap <- function(geojson, feat, output, incident) {
    
    geojson$features <- lapply(geojson$features, function(feat) {
        i = feat$properties[incident]
        state_popup <- paste(i)
        feat$properties$style <- list(
            #fillColor = getColor(i)
        )
        feat
    })
    
    
    output$map <- renderLeaflet({
        leaflet() %>% addGeoJSON(geojson) %>% 
            addLegend("bottomright", 
                      colors =c("#BD0026",  "#E31A1C", "#FC4E2A", "#FD8D3C", "#FEB24C", "#FED976", "#FFEDA0"),
                      labels= c("100%", "75% - 100%","50% - 75%","25% - 50%","10% - 25%", "5% - 10%", "0% - 5%"),
                      title= "% de incidencia",
                      opacity = 1) %>% 
            setView(lat = 41.9505 , lng = 0.8677, zoom = 8)
    })
}


# Funció per fer un degradat de colors al mapa utilitzant la variable incidencia
getColor <- function(incidencia) {
    if (is.null(incidencia)) return("#FFFFFF")
    else {
      if (incidencia >= 100) return ("#BD0026")
      else if (incidencia > 75) return ("#E31A1C")
      else if (incidencia > 50) return ("#FC4E2A")
      else if (incidencia > 25) return ("#FD8D3C")
      else if (incidencia > 10) return ("#FEB24C")
      else if (incidencia > 5) return ("#FED976")
      else return ("#FFEDA0")      
    }

}



printTable <- function(output, valueRb){
  print(valueRb)
  output$distribucio_taula <- renderDataTable({
    df_distribucio_taula = read.csv('dones-rural-2012.csv',sep=';')
    if(valueRb == "dr12") df_distribucio_taula = read.csv('dones-rural-2012.csv',sep=';')
    else if(valueRb == "du12") df_distribucio_taula = read.csv('dones-urba-2012.csv',sep=';')
    else if(valueRb == "hr12") df_distribucio_taula = read.csv('homes-rural-2012.csv',sep=';')
    else if(valueRb == "hu12") df_distribucio_taula = read.csv('homes-urba-2012.csv',sep=';')
    else if(valueRb == "dr13") df_distribucio_taula = read.csv('dones-rural-2013.csv',sep=';')
    else if(valueRb == "du13") df_distribucio_taula = read.csv('dones-urba-2013.csv',sep=';')
    else if(valueRb == "hr13") df_distribucio_taula = read.csv('homes-rural-2013.csv',sep=';')
    else if(valueRb == "hu13") df_distribucio_taula = read.csv('homes-urba-2013.csv',sep=';')
    else if(valueRb == "dr14") df_distribucio_taula = read.csv('dones-rural-2014.csv',sep=';')
    else if(valueRb == "du14") df_distribucio_taula = read.csv('dones-urba-2014.csv',sep=';')
    else if(valueRb == "hr14") df_distribucio_taula = read.csv('homes-rural-2014.csv',sep=';')
    else if(valueRb == "hu14") df_distribucio_taula = read.csv('homes-urba-2014.csv',sep=';')
    totals <- htmltools::withTags(table(
      tableHeader(df_distribucio_taula),
      #tableFooter(sapply(df_incidencia_provincia_lleida_homes, function(x) if(is.numeric(x)) sum(x)))
    ))
    
    DT::datatable(df_distribucio_taula,
                  container=totals,
                  #caption = tags$caption("Example"), 
                  rownames = F, options = list(autoWidth = T, 
                                               paging=F,
                                               scrollCollapse = T,
                                               dom = 'lftp')
    )
    
  })
  
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

# Menu
sidebar <- dashboardSidebar(
    sidebarMenu(
        tags$head(tags$style(HTML('.content-wrapper { height: 1500px !important;}'))),
        menuItem("Menu Principal", tabName = "resum", icon = icon("dashboard")),
        menuItem("MAPA ABS", tabName = "incidencia", icon = icon("map")),
        menuItem("Pirámide de població", tabName = "populationpyramid", icon = icon("info"))
        #menuItem("Taxes i correlacions", icon = icon("th"), tabName = "distribucions")
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
                        title = "Nº de receptes",
                        status = "info",
                        width =12,
                        #plotOutput(outputId = "recep_plot", height = 500)
                        plotlyOutput(outputId = "recep_plot", height = 500)
                    )          
                            
            ),
            tabItem(tabName = "incidencia",
                leafletOutput("plot_abs")
            ),
        tabItem(tabName = "distribucions",
            h2("Distribucions totals del càncer"),
            column(width = 12,
            ),
            # box( title = "Taula de distribució", status = "primary", height =
            #          "100%",width = "12",solidHeader = T,
            #      column(width = 12,
            #             DT::dataTableOutput("distribucio_taula"),style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
            #      )
            # ),
            # 
            # box( title = "Taula de distribució", status = "primary", height =
            #        "595",width = "6",solidHeader = T,
            #      column(width = 12,
            #             DT::dataTableOutput("distribucio_taula"),style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
            #     )
            # ),
             
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
    abs <- readOGR("/srv/shiny-server/maps/ABS_2018.shp",
                layer = "ABS_2018", GDAL1_integer64_policy = TRUE, use_iconv=TRUE, encoding="UTF-8")

    output$plot_abs <- renderLeaflet({
        leaflet(abs) %>%
        setView(lng = 1.3984735784516196, lat = 42.091848475624886, zoom = 8) %>%
        addTiles() %>%
        #addProviderTiles(providers$Esri.WorldTopoMap) %>%
        addPolygons(color = "#FF0000", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    #fillColor = ~colorQuantile("YlOrRd", NA.)(NA.),
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE))
    })

    #TODO: Permetre carregar el mapa de comarca o municipi en funcio de la selecció de l'usuari
    

    output$txt <- renderText({
        paste("You choose", input$rb)
    })

    output$list <- renderText({
        paste("You choose", input$cancerList)
    })
    
    ########### Secció Inicial - Dashboard
     
    # Observem tots els events en incidencies, en cas que un usuari faci una selecció repintem el mapa.
    v <- observeEvent(req(input$rb,input$cancerList),{ 
        
        if(input$rb =="Homes"){
            sexe <- 'Homes'}
        if(input$rb =="Dones"){
            sexe <- 'Dones'}
        
        for(i in cancers){
            if(input$cancerList == i){
                cancer <- i
            }
        }
        
        print(cancer)
        print(sexe)
        incident <- paste("incident", cancer, sexe, sep="")
        printMap(geojson, feat, output, incident)
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

    #output$recep_plot <- renderPlot({
    #plotRecep()
    #})

    output$recep_plot <- renderPlotly({
    plotRecep("946582")
    })

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
  })
    
}



options(shiny.autoreload = TRUE)
shinyApp(ui, server)