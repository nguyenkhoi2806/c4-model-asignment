workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "An internal user of a bookstore system refers to an individual or group of individuals who work within the bookstore" "User"

        # Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "Bookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            searchWebApi = container "Search API" "Allows only authorized users searching books records via HTTPS API" "Go"
            adminWebApi = container "Admin Web API" "Allows only internal users to manage books and purchases information using HTTPs" "Go" {
                # Level 3: Components
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authService = component "Authorizer" "Authorize users by using external Authorization System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Events Publisher" "Go"
            }
            publicWebApi = container "Public Web API" "Allows public users getting books information using HTTPS" "Go"
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventStream = container "Book Event System" "Handles book-related domain events" "Apache Kafka 3.0"
            bookEventConsumer = container "Book Event Consumer" "Handle book update events" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"
            frontStoreApplication = container "Front store application" "Provide all the bookstore functionalities" "JavaScript & ReactJS"
            backOfficeApplication = container "Back-office Application" "Provide all the bookstore administration functionalities" "JavaScript & ReactJS"
        }
        
        # External Software Systems
        authSystem = softwareSystem "Identity Provider System" "The external Identiy Provider Platform for authorization purposes" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about books published by them" "External System"
        shippingServices = softwareSystem "Shipping Service" "The 3rd party system of Shipping Service to handle book delivery" "External System"

        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> frontStoreApplication "Use all bookstore functionalities"
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> frontStoreApplication "Use all bookstore functionalities"
        authorizedUser -> bookstoreSystem "Search book with more details, administrate books and their details"
        internalUser -> bookstoreSystem "Manage inventory, manage customers, manage orders, view report"
        internalUser -> backOfficeApplication "Use all administration functionalities"
        bookstoreSystem -> authSystem "Register new user, and authorize user access"
        publisherSystem -> bookstoreSystem "Publish events for new book publication, and book information updates" {
            tags "Async Request"
        }
        bookstoreSystem -> shippingServices "Handle the book delivery"

        # Relationship between Containers
        frontStoreApplication -> publicWebApi "Place order" "Interact"
        publicUser -> publicWebApi "Search books information" "JSON/HTTPS"
        publicWebApi -> bookstoreDatabase "Retrieve book search and read/write  data" "ODBC"
        authorizedUser -> searchWebApi "Search book with more details" "JSON/HTTPS"
        frontStoreApplication -> searchWebApi "Search book" "Interact"
        searchWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        searchWebApi -> searchDatabase "Retrieve book search data" "ODBC"
        backOfficeApplication -> adminWebApi "administrate books and purchases" "Interact"
        internalUser -> adminWebApi "Administrate books and their details" "JSON/HTTPS"
        adminWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        adminWebApi -> bookstoreDatabase "Reads/Write the data" "ODBC"
        adminWebApi -> bookEventStream "Publish book update events" {
            tags "Async Request"
        }
        bookEventStream -> bookEventConsumer "Consume book update events"
        bookEventConsumer -> searchDatabase "Write and search data" "ODBC"
        publisherRecurrentUpdater -> adminWebApi "Update the data changes" "JSON/HTTPS" "Use"

        # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "Consume book publication update events" {
            tags "Async Request"
        }

        # Relationship between Components
        publisherRecurrentUpdater -> bookService "Makes API calls to" "JSON/HTTPS"
        bookService -> authService "Uses"
        bookService -> bookEventPublisher "Uses"
        internalUser -> authService "Uses"

        # Relationship between Components and Other Containers
        authService -> authSystem "Authorize user permissions" "JSON/HTTPS"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        bookEventPublisher -> bookEventStream "Handle the book-published event"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout lr
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout lr
        }


        styles {
            # element <tag> {}
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}