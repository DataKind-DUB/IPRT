library(SPARQL)
library(tidyverse)
library(ggmap)

# Example 1: Movie stars 
# http://linkedscience.org/tools/sparql-package-for-r/sparql-package-for-r-gephi-movie-star-graph-visualization-tutorial/ 

endpoint <- "http://live.dbpedia.org/sparql"
prefix <- c("db","http://dbpedia.org/resource/")
sparql_prefix <- "PREFIX dbp: <http://dbpedia.org/property/>
                  PREFIX dc: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
"

q <- paste(sparql_prefix,
           'SELECT ?actor ?movie ?director ?movie_date
           WHERE {
           ?m dc:subject <http://dbpedia.org/resource/Category:American_films> .
           ?m rdfs:label ?movie .
           FILTER(LANG(?movie) = "en")
           ?m dbp:released ?movie_date .
           FILTER(DATATYPE(?movie_date) = xsd:date)
           ?m dbp:starring ?a .
           ?a rdfs:label ?actor .
           FILTER(LANG(?actor) = "en")
           ?m dbp:director ?d .
           ?d rdfs:label ?director .
           FILTER(LANG(?director) = "en")
           }')


res <- SPARQL(endpoint,q,ns=prefix)$results



res$movie_date <-
  as.Date(as.POSIXct(res$movie_date, origin = "1970-01-01"))

res %>%  View()



# Example 3
# https://www.w3.org/2009/Talks/0615-qbe/ - query #4

endpoint <- "http://dbpedia.org/sparql"
prefix <- c("db","http://dbpedia.org/resource/")

sparql_prefix <- "PREFIX dbp: <http://dbpedia.org/property/>
                  PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>"

q <- "SELECT DISTINCT ?concept ?id
      WHERE {
      ?s a ?concept .
      } LIMIT 200
      "
res <- SPARQL(endpoint, q)

res$results %>% View()
