# Instalacja i załadowanie niezbędnych pakietów
install.packages(c("shiny", "jsonlite", "plotly", "RCurl"))
library(shiny)
library(jsonlite)
library(plotly)
library(RCurl)

# Definicja interfejsu użytkownika Shiny
ui <- fluidPage(
  titlePanel("Wykresy z pliku JSON z FTP"),
  sidebarLayout(
    sidebarPanel(
      textInput("ftp_host", "Host FTP", ""),
      textInput("ftp_username", "Nazwa użytkownika FTP", ""),
      passwordInput("ftp_password", "Hasło FTP", ""),
      textInput("ftp_file_path", "Ścieżka pliku JSON na serwerze FTP", ""),
      actionButton("load_button", "Wczytaj plik")
    ),
    mainPanel(
      plotlyOutput("temperature_plot"),
      plotlyOutput("humidity_plot"),
      plotlyOutput("pressure_plot"),
      plotlyOutput("analog_plot")
    )
  )
)

# Definicja funkcji serwera Shiny
server <- function(input, output) {
  
  # Wczytywanie danych z pliku JSON z serwera FTP
  json_data <- reactive({
    req(input$load_button)
    url <- sprintf("ftp://%s:%s@%s%s", input$ftp_username, input$ftp_password, input$ftp_host, input$ftp_file_path)
    data <- fromJSON(getURL(url, ftp.use.epsv = FALSE))
    data
  })
  
  # Tworzenie interaktywnych wykresów
  output$temperature_plot <- renderPlotly({
    plot_ly(data = json_data(), x = ~received_at, y = ~uplink_message$decoded_payload$temperature_2, type = 'scatter', mode = 'lines', name = 'Temperature', line = list(color = 'red')) %>%
      layout(title = 'Temperatura w czasie', xaxis = list(title = 'Received At'), yaxis = list(title = 'Temperature'))
  })
  
  output$humidity_plot <- renderPlotly({
    plot_ly(data = json_data(), x = ~received_at, y = ~uplink_message$decoded_payload$relative_humidity_3, type = 'scatter', mode = 'lines', name = 'Humidity', line = list(color = 'blue')) %>%
      layout(title = 'Wilgotność w czasie', xaxis = list(title = 'Received At'), yaxis = list(title = 'Humidity'))
  })
  
  output$pressure_plot <- renderPlotly({
    plot_ly(data = json_data(), x = ~received_at, y = ~uplink_message$decoded_payload$barometric_pressure_4, type = 'scatter', mode = 'lines', name = 'Barometric Pressure', line = list(color = 'green')) %>%
      layout(title = 'Ciśnienie atmosferyczne w czasie', xaxis = list(title = 'Received At'), yaxis = list(title = 'Barometric Pressure'))
  })
  
  output$analog_plot <- renderPlotly({
    plot_ly(data = json_data(), x = ~received_at, y = ~uplink_message$decoded_payload$analog_in_1, type = 'scatter', mode = 'lines', name = 'Analog In', line = list(color = 'orange')) %>%
      layout(title = 'Sygnał analogowy w czasie', xaxis = list(title = 'Received At'), yaxis = list(title = 'Analog In'))
  })
}

# Uruchomienie aplikacji Shiny
shinyApp(ui, server)
