library(shiny)
library(readr)
library(stringr)
library(writexl)

ui <- fluidPage(
  hr(),
  fileInput("file", label = "ログファイル(UTF8)を選択して下さい"),
  hr(),
  actionButton("submit", "エラーチェックを返します"),
  hr(),
  tableOutput("result_table"),  # 表形式で表示
  hr(),
  downloadButton("download_excel", "Excelでダウンロード")
)

server <- function(input, output, session) {
  result_data <- reactiveVal(NULL)

  observeEvent(input$submit, {
    req(input$file)
    text <- read_file(input$file$datapath)
    df <- data.frame(
      キーワード = c("ERROR", "エラー", "WARNING", "欠損", "無効", "欠落"),
      件数 = c(
        str_count(text, "ERROR"),
        str_count(text, "エラー"),
        str_count(text, "WARNING"),
        str_count(text, "欠損"),
        str_count(text, "無効"),
        str_count(text, "欠落")
      )
    )
    result_data(df)
  })

  output$result_table <- renderTable({
    result_data()
  })

  output$download_excel <- downloadHandler(
    filename = function() {
      paste0("error_check_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      write_xlsx(result_data(), path = file)
    }
  )

  session$onSessionEnded(function() {
    stopApp()
  })
}

shinyApp(ui = ui, server = server)
