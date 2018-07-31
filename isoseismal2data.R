############################################################
#create event data from the isoseismal map of Al-Tarazi 2000
############################################################
library(rgdal)
library(raster)
library(sp)

setwd("/home/mhaas/PhD/Routines/isoseismal2data/")
isoseismals <- readOGR(dsn="/home/mhaas/PhD/Routines/isoseismal2data",layer="Shakemap_1995_lines")

#lay raster over region of shapefile
int_data <- raster(ext=extent(isoseismals),crs=isoseismals@proj4string,resolution=0.1)

#Treating isoseismsals as polygons wrong actually --> commented out
# #for each raster cell check in which of the polygons it is contained and which is the smallest
# values=c()
# for (cell in seq_along(int_data)){
#   xy <- xyFromCell(int_data,cell,spatial=TRUE)
#   x <- xy@coords[[1]]
#   y <- xy@coords[[2]]
#   smallest_area = 10^100
#   mmi <- 2
#   for (i in seq_along(isoseismals)){
#     coords <- isoseismals@polygons[[i]]@Polygons[[1]]@coords
#     area <- isoseismals@polygons[[i]] @Polygons[[1]]@area
#     if (point.in.polygon(x,y,coords[,1],coords[,2]) && area < smallest_area){
#       smallest_area <- area
#       mmi <- isoseismals@data$MMI[i] 
#     }
#   }
#   values <- append(values,mmi)
# }
# 
# #write values to raster
# values(int_data) <- values
# plot(int_data)

#rasterize the lines ()
int_data <- rasterize(x=isoseismals,y=int_data,field=isoseismals@data$MMI)
#collect data in data.frame
z <- values(int_data)
#idx all values which are not z=na
idx <- seq_along(int_data)
idx <- idx[-which(is.na(z))]
df <- data.frame()
for (i in idx){
  xy <- xyFromCell(int_data,i)
  zval  <- z[i]
  df <- rbind(df,c(xy,zval))
}
colnames(df) <-c('x','y','z')

#downsampling this to ~1/10 bcs isoseismals are not actual observations
#and we don't want to bias our ranking bcs of this!
idx <- seq_along(df$x)
idx <- idx[which(idx%%10==0)]
df2 <- data.frame(df$x[idx],df$y[idx],df$z[idx])
colnames(df2) <-c('x','y','z')

#plot
library(ggplot2)

p <- ggplot(df2,aes(x,y))
p + geom_point(aes(color=z))
#write to csv
write.csv(x=df2,file='int_data.csv')





