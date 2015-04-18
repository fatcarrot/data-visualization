library(maptools)
library(ggplot2)
library(plyr)

png("airport.png", width = 9600, height = 9600, family="GB1"); 
world = readShapePoly("/Users/yucan/Desktop/map_data/world.shp")
worldmap <- fortify(world)

#center <- 115
center <- 150
worldmap$long.recenter <- ifelse(worldmap$long < center - 180, worldmap$long + 360, worldmap$long)

# 开始写原始算法替换函数 世界地图重分组
worldmap.mean <- aggregate(x = worldmap[, c("long.recenter")], by = list(worldmap$group), FUN = mean)
worldmap.min  <- aggregate(x = worldmap[, c("long.recenter")],  by = list(worldmap$group), FUN = min)
worldmap.max  <- aggregate(x = worldmap[, c("long.recenter")],  by = list(worldmap$group), FUN = max)
worldmap.md   <- cbind(worldmap.mean, worldmap.min[, 2], worldmap.max[, 2])
colnames(worldmap.md) <- c("group", "mean", "min", "max")
worldmapt <- join(x = worldmap, y = worldmap.md, by = c("group"))
worldmapt$group.regroup <- 1
worldmapt[(worldmapt$max > 180) & (worldmapt$min < 180) & (worldmapt$long.recenter > 180), c("group.regroup")] <- 2
worldmapt$group.regroup <- paste(worldmapt$group, worldmapt$group.regroup, sep = ".")
worldmap.rg <- worldmapt

# 闭合曲线
worldmap.rg <- worldmap.rg[order(worldmap.rg$group.regroup, worldmap.rg$order), ]
worldmap.begin <- worldmap.rg[!duplicated(worldmap.rg$group.regroup), ]
worldmap.end <- worldmap.rg[c(!duplicated(worldmap.rg$group.regroup)[-1], TRUE), ]
worldmap.flag <- (worldmap.begin$long.recenter == worldmap.end$long.recenter) & (worldmap.begin$lat == worldmap.end$lat)
table(worldmap.flag)
worldmap.plus <- worldmap.begin[!worldmap.flag, ]
worldmap.end[!worldmap.flag, ]
worldmap.plus$order <- worldmap.end$order[!worldmap.flag] + 1
worldmap.cp <- rbind(worldmap.rg, worldmap.plus)
worldmap.cp <- worldmap.cp[order(worldmap.cp$group.regroup, worldmap.cp$order), ]

airport <- read.table("/Users/yucan/Desktop/airport.data", sep = '\t', fileEncoding="UTF-8");
airport$long.recenter <- ifelse(airport$V11 < center - 180, airport$V11 + 360, airport$V11)
nr <- nrow(airport)

china = readShapePoly("/Users/yucan/Desktop/map_data/BOUNT_poly.shp")
chinamap <- fortify(china)
chinamap$long.recenter <- ifelse(chinamap$long < center - 180, chinamap$long + 360, chinamap$long)
mymap <- geom_polygon(data = chinamap, aes(x = long.recenter, y = lat, group = id), size=1, colour = "gray", fill = NA)

province = readShapePoly("/Users/yucan/Desktop/map_data/bou2_4p.shp")
provincemap <- fortify(province)
provincemap$long.recenter <- ifelse(provincemap$long < center - 180, provincemap$long + 360, provincemap$long)
mymap2 <- geom_polygon(data = provincemap, aes(x = long.recenter, y = lat, group = id), size=2, colour = "black", fill = NA)

wrld <- geom_polygon(aes(long.recenter, lat, group = group.regroup, fill = group.regroup), colour = "black", size = 1, alpha = I(2/5), data = worldmap.cp)
print(ggplot() + theme(panel.background = element_blank(), legend.position="none") + wrld + mymap + mymap2 + ylim(-80, 90) + coord_map() + geom_point(data=airport, size=15, aes(x=long.recenter, y=V12, colour=V8),alpha=I(1)) + annotate(rep("text", nr), x=airport$long.recenter, y=airport$V12, size=rep(5, nr), label=airport$V2))
