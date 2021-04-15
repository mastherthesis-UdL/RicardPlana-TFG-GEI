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

# Funció per imprimer una piràmide poblacional 
# @df = dataframe amb tres columnes Edat,Valor i Sexe
plotPyramide <- function(df){ 
    
    p <- ggplot(df, aes(x = Edat, y = Valor, fill = Sexe)) +
        geom_bar(stat = "identity") +
        facet_share(df$Sexe, dir = "h", reverse_num = FALSE) +  
        coord_flip() +
        scale_y_continuous() + 
        theme_minimal() +
        labs(y = "# Casos", x = "Grups d'edat", title = " ") +
        scale_fill_manual(values = c("pink", "blue"))
    p <- p + theme(text = element_text(size = 16))
    
    return(p)
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


# Menu
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Resum", tabName = "resum", icon = icon("calendar")),
        menuItem("Incidència", tabName = "incidencia", icon = icon("map"))
        #menuItem("Taxes i correlacions", icon = icon("th"), tabName = "distribucions")
    )
)
url <- ("http://kenpom.com/team.php?team=Rice")
# Cos del Dashboard amb les seve parts
body <- dashboardBody(
    tabItems(
            tabItem(tabName = "resum",
                    h2("Resum dades analitzades"),
                    fluidRow(
                      # A static valueBox
                      valueBox(1420, "Total homes", icon = icon("male"), color = "aqua"),
                      valueBox(978, "Total dones", icon = icon("female"), color = "blue"),
                      valueBox(2398, "Total pacients", icon = icon("users"), color = "light-blue"),
                      valueBox(2427, "Total tumors", icon = icon("user-md"), color = "teal"),
                      valueBox(2014, "Any d'estudi", icon = icon("calendar"), color = "olive"),
                      valueBox(431.375, "Població total", icon = icon("globe"), color = "purple"),

                    ),
                    box( title = "Taula de incidència a Lleida per Homes", status = "primary", height =
                           "595",width = "6",solidHeader = T,
                         column(width = 12,
                                DT::dataTableOutput("incidencia_provincia_lleida_homes"),style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
                         )
                    ),
                    box( title = "Taula de incidència a Lleida per Dones", status = "primary", height =
                           "595",width = "6",solidHeader = T,
                         column(width = 12,
                                DT::dataTableOutput("incidencia_provincia_lleida_dones"),style = "height:500px; overflow-y: scroll;overflow-x: scroll;"
                         )
                    )
            ),
            tabItem(tabName = "incidencia",
                    h2("Mapa d'incidència del càncer a la província de Lleida"),
                    fluidRow(
                    column(width = 9,
                       box(width = NULL, solidHeader = TRUE,
                           leafletOutput("map", height = 500)
                       ),
                       box(width = NULL,
                           uiOutput("numVehiclesTable")
                       )
                    ),
                    column(width = 3,
                       box(width = NULL, status = "warning",
                           radioButtons("rbZ", "Escull el zoom:",
                                        choiceNames = list(
                                            "Comarca",
                                            "Municipi"
                                        ),
                                        choiceValues = list(
                                            "Comarca", "Municipi"
                                        )
                           ),
                           radioButtons("rb", "Escull el sexe:",
                                        choiceNames = list(
                                            "Homes",
                                            "Dones"
                                        ),
                                        choiceValues = list(
                                            "Homes", "Dones"
                                        )
                           ),
                           selectInput("cancerList", "Tipus de càncer",
                                       choices = c(
                                           "Pulmó" = "Pulmo",
                                           "Mama" = "Mama",
                                           "Còlon" = "Colon",
                                           "Recte" = "Recte",
                                           "Pròstata" = "Prostata",
                                           "Bufeta" = "Bufeta",
                                           "Mieloma" = "Mieloma",
                                           "Estómac" = "Estomac",
                                           "Endometri" = "Endometri",
                                           "Pell" = "Pell",
                                           "Ossos" = "Ossos"
                                       ),
                                       selected = "pulmo"
                           ), textOutput("list")
                       )
                )
            )
            ),
        tabItem(tabName = "distribucions",
            h2("Distribucions totals del càncer"),
            column(width = 12,
                   box(width = NULL, status = "warning",
                       radioButtons("rbDist", "Escull la taula:",
                                    choiceNames = list(
                                      "Dones Rural 2012",
                                      "Homes Rural 2012",
                                      "Dones Urbà 2012",
                                      "Homes Urbà 2012",
                                      "Dones Rural 2013",
                                      "Homes Rural 2013",
                                      "Dones Urbà 2013",
                                      "Homes Urbà 2013",
                                      "Dones Rural 2014",
                                      "Homes Rural 2014",
                                      "Dones Urbà 2014",
                                      "Homes Urbà 2014"
                                    ),
                                    choiceValues = list(
                                      "dr12", "hr12", "du12", "hu12", "dr13", "hr13", "du13", "hu13", "dr14", "hr14", "du14", "hu14"
                                    ),
                                    inline = TRUE
                       ),

                   )
            )
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
            # box(
            #     title = "Gràfica de la distribució",
            #     status = "info",
            #     plotOutput(
            #         outputId = "distribution_plot", height = 250)
            # )
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
    # Inicialització de valors
    cancers <- cancerTypes()
    incident=''
    sexe ='Homes'
    cancer='Pulmo'
    zoom='Comarca'
    
    
    #TODO: Permetre carregar el mapa de comarca o municipi en funcio de la selecció de l'usuari
    
    geojson <- readLines("comarques-lleida.geojson", warn = FALSE) %>%
        paste(collapse = "\n") %>%
        fromJSON(simplifyVector = FALSE)
    
    # Incidencia estimate from all comarques
    incidencia <- sapply(geojson$features, function(feat) {
        feat$properties$incidencia
    })
    
    # Default styles for all features
    geojson$style = list(
        weight = 1,
        color = "#555555",
        opacity = 1,
        fillOpacity = 0.8
    )
    

    output$txt <- renderText({
        paste("You choose", input$rb)
    })

    output$list <- renderText({
        paste("You choose", input$cancerList)
    })
    
    ########### Secció Inicial - Dashboard
    
    # Taula homes
    output$incidencia_provincia_lleida_homes <- renderDataTable({
      df_incidencia_provincia_lleida_homes = read.csv('incidencia_provincia_lleida_homes.csv',sep=';')
      totals <- htmltools::withTags(table(
        tableHeader(df_incidencia_provincia_lleida_homes),
        #tableFooter(sapply(df_incidencia_provincia_lleida_homes, function(x) if(is.numeric(x)) sum(x)))
      ))
      
      DT::datatable(df_incidencia_provincia_lleida_homes,
                    container=totals,
                    #caption = tags$caption("Example"), 
                    rownames = F, options = list(autoWidth = T, 
                                                 paging=F,
                                                 scrollCollapse = T,
                                                 dom = 'lftp')
      )
      
    })
    
    # Taula dones
    output$incidencia_provincia_lleida_dones <- renderDataTable({
      incidencia_provincia_lleida_dones = read.csv('incidencia_provincia_lleida_dones.csv',sep=';')
      totals <- htmltools::withTags(table(
        tableHeader(incidencia_provincia_lleida_dones),
        tableFooter(sapply(incidencia_provincia_lleida_dones, function(x) if(is.numeric(x)) sum(x)))
      ))
      
      DT::datatable(incidencia_provincia_lleida_dones,
                    container=totals,
                    #caption = tags$caption("Example"), 
                    rownames = F, options = list(autoWidth = T, 
                                                 paging=F,
                                                 scrollCollapse = T,
                                                 dom = 'lftp')
      )
      
    })

    
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
    
    observeEvent(input$map_click, {
      print(2)
      click <- input$map_click
      print(click)
      text<-paste("Lattitude ", click$lat, " Longitud ", click$lng)
      incident <- paste("incident", cancer, sexe, sep="")

      proxy <- leafletProxy("map")
      proxy %>% clearPopups() %>%
        addPopups(click$lng, click$lat, text)
    })

    ########### Secció Distribució
    
    #TODO: Fer.la dinàmica per mostrar totes les taules.

    # Taula
    output$distribucio_taula <- renderDataTable({
        df_distribucio = read.csv('distribucio-taula.csv',sep=';')
        totals <- htmltools::withTags(table(
            tableHeader(df_distribucio),
            tableFooter(sapply(df_distribucio, function(x) if(is.numeric(x)) sum(x)))
        ))
        
        DT::datatable(df_distribucio,
                      container=totals,
                      caption = tags$caption("Example"), 
                      rownames = F, options = list(autoWidth = T, 
                                 paging=F,
                                 scrollCollapse = T,
                                 dom = 'lftp')
                  )
        
    })
    
    v2 <- observeEvent(input$rbDist, {
      #print(input$rbDist)
      printTable(output, input$rbDist)
    })
    
    
    
    
    #TODO: Fer.la dinàmica per mostrar totes les taules.
    
    # Taula
    output$distribucio_taula1 <- renderDataTable({
      df_distribucio_taula1 = read.csv('dones-rural-2012.csv',sep=';')
      totals <- htmltools::withTags(table(
        tableHeader(df_distribucio_taula1),
        tableFooter(sapply(df_distribucio_taula1, function(x) if(is.numeric(x)) sum(x)))
      ))
      
      DT::datatable(df_distribucio_taula1,
                    container=totals,
                    caption = tags$caption("Example"), 
                    rownames = F, options = list(autoWidth = T, 
                                                 paging=F,
                                                 scrollCollapse = T,
                                                 dom = 'lftp')
      )
      
    })
    
    # Piramide d'Edat
    #df_distribucio2 = read.csv('distribucio-taula2.csv',sep=';')
    #output$distribution_plot <- renderPlot({
    #    p<-plotPyramide(df_distribucio2)
    #    print(p)
    #})
    
    ########### Secció Analisis Exploratori
    #TODO: Migrar tot el dashboard estátic cap a qui
    
}




shinyApp(ui, server)