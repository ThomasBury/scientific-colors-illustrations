unemp <- read.csv("http://datasets.flowingdata.com/unemployment09.csv",
                  header = FALSE, stringsAsFactors = FALSE)
names(unemp) <- c("id", "state_fips", "county_fips", "name", "year",
                  "?", "?", "?", "rate")
unemp$county <- tolower(gsub(" County, [A-Z]{2}", "", unemp$name))
unemp$county <- gsub("^(.*) parish, ..$","\\1", unemp$county)
unemp$state <- gsub("^.*([A-Z]{2}).*$", "\\1", unemp$name)

county_df <- map_data("county", projection = "albers", parameters = c(39, 45))






names(county_df) <- c("long", "lat", "group", "order", "state_name", "county")
county_df$state <- state.abb[match(county_df$state_name, tolower(state.name))]
county_df$state_name <- NULL

state_df <- map_data("state", projection = "albers", parameters = c(39, 45))

choropleth <- merge(county_df, unemp, by = c("state", "county"))
choropleth <- choropleth[order(choropleth$order), ]






plot_county <- ggplot(choropleth, aes(long, lat, group = group)) +
  geom_polygon(aes(fill = rate), colour = alpha("white", 1 / 2), size = 0.01) +
  geom_polygon(data = state_df, colour = "white", fill = NA, size = 0.025) +
  coord_fixed() +
  theme_minimal() +
  ggtitle("US unemployment rate by county") +
  theme(axis.line = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), axis.title = element_blank()) 


for (i in seq(1,5)) {
  plot_county <- plot_county + scale_fill_viridis(option=LETTERS[i])
  print(plot_county)
}



###############
#    Italy    #
###############

library(maptools)
library(ggplot2)
library(ggalt)
library(ggthemes)
library(tibble)
library(viridis)

# get italy region map
italy_map <- map_data("italy")

# your data will need to have these region names
print(unique(italy_map$region))

# we'll simulate some data for this
set.seed(1492)
choro_dat <- data_frame(region=unique(italy_map$region),
                        value=sample(100, length(region)))

# we'll use this in a bit
italy_proj <- "+proj=aea +lat_1=38.15040684902542
+lat_2=44.925490198742295 +lon_0=12.7880859375"

gg <- ggplot()

# lay down the base layer
gg <- gg + geom_map(data=italy_map, map=italy_map,
                    aes(long, lat, map_id=region),
                    color="#b2b2b2", size=0.1, fill=NA)

# fill in the regions with the data
gg <- gg + geom_map(data=choro_dat, map=italy_map,
                    aes(fill=value, map_id=region),
                    color="#b2b2b2", size=0.1)

# great color palette (use a better legend title)
gg <- gg + scale_fill_viridis(name="Scale title")

# decent map projection for italy choropleth
gg <- gg + coord_proj(italy_proj)

# good base theme for most maps
gg <- gg + theme_map()

# move the legend
gg <- gg + theme(legend.position=c(0.95, 0.3))

gg


