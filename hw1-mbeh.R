# Homework 1
# By Min Yan BEH (mbeh)

# If titanic dataset doesn't exist, run code below:
# install.packages("titanic")

library(shiny)
library(reshape2)
library(dplyr)
library(plotly)
library(DT)
library(plyr)
library(titanic)

# Use only train data as test data doesn't have Survived label
titanic_data <- titanic_train
min_age <- min(titanic_data$Age, na.rm = T)
max_age <- max(titanic_data$Age, na.rm = T)
pdf(NULL)


# Define UI for application that draws a scatter plot of people who survived or not
ui <- fluidPage(
  
  # Application title
  titlePanel("The Titanic: Who Survived?"),
  
  # Sidebar
  sidebarLayout(
    sidebarPanel(
      # selection input for passenger class
      selectInput("pclass_select",
                  "Passenger Class:",
                  choices = paste("Class", as.character(seq(3))),
                  multiple = TRUE,
                  selectize = TRUE,
                  selected = paste("Class", as.character(seq(3)))),
      
      # sliding range input for defining min/max passenger age
      sliderInput("age_range", 
                  "Age Range:",
                  min = min_age,  # So users can't make filters that have no data I would do this in the future min(titantic_data$Age, na.rm = T)
                  max = max_age, # Like wise: max(titantic_data$Age, na.rm = T)
                  value = c(min_age, max_age) # c(min(titantic_data$Age, na.rm = T),max(titantic_data$Age, na.rm = T))
      )
    ),
    mainPanel(
      
      # Tabs for plot and table
      tabsetPanel(
        tabPanel("Plot", 
                 plotlyOutput("plot")
        ),
        tabPanel("Table",
                 DT::dataTableOutput("table")
        )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$plot <- renderPlotly({
    
    # Filter plot data based on passenger class and age range inputs
    min_age <- input$age_range[1]
    max_age <- input$age_range[2]
    plot_data <- filter(titanic_data, paste("Class", Pclass) %in% input$pclass_select, 
                        Age >= min_age, Age <= max_age)
    
    # Define function (used by ggplot) that customizes text displayed for 0/1 Survived label
    get_label_for_Survived_column <- function(variable, value){
      ifelse(value == "1", "Survived", "Did not survive")
    }
    
    plot <- ggplot() +
      geom_jitter(data = plot_data, aes(Pclass, Age, colour = factor(Sex), text = paste0("Age: ", Age, "<br>",
                                                                                         "Class: ", Pclass, "<br>",
                                                                                         "Sex: ", Sex ))) + 
      facet_grid(Survived ~ ., labeller = get_label_for_Survived_column) +
      # show integral values on x axis
      scale_x_continuous(breaks = function(x) seq(max(x))) + 
      scale_color_brewer(palette = "Set1") +
      # configure axis/legend labels and themes
      ggtitle("Survival of Titanic Passengers : by Age, Sex, Passenger Class") +
      xlab("Passenger Class") +
      labs(color = "Sex") +
      theme_gray()
    
    ggplotly(plot, tooltip = "text") %>%
      layout(height = 600, legend = list(orientation = "h", x = 0, y = -0.1))
  })
  
  output$table <- DT::renderDataTable({
    min_age <- input$age_range[1]
    max_age <- input$age_range[2]
    
    # Customize text displayed for 0/1 Survived label: "Yes"/"No"
    titanic_data %>% mutate(Survived = plyr::revalue(as.character(Survived), c("0" = "No", "1" = "Yes"))) %>%
      
      # Filter table data based on passenger class and age range inputs
      filter(paste("Class", Pclass) %in% input$pclass_select, Age >= min_age, Age <= max_age) %>% 
      
      # Define list of data columns used by table
      subset(select = c("Name", "Sex", "Age", "Pclass", "Survived"))
  }, 
  # Modify Passenger Class column name for readability
  colnames = c("Name", "Sex", "Age", "Passenger Class", "Survived")
  )
}

# Run the application 
shinyApp(ui = ui, server = server)