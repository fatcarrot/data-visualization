library(maptools)
library(ggplot2)
library(geosphere)

#生成数据路径
argv <- commandArgs(TRUE)
device.data.path   <- paste("./", argv[1], sep="")
signal.data.path   <- paste("./", argv[2], sep="")
flight.data.path   <- paste("./", argv[3], sep="")
airport.data.path  <- paste("./", argv[4], sep="")
area_jwd.data.path <- paste("./", argv[5], sep="")
day <- argv[6]

png(paste("./result/device_airport_signal_", day, ".png", sep=""), width=9600,
    height=9600, family="GB1")

#读取设备位置数据
device <- read.table(device.data.path, sep='\t',
    fileEncoding="UTF-8", comment.char="^")
device <- subset(device, V3>1)
device <- subset(device, V4>1)
dev_rows <- grep('DEV_', device$V1)
device.profession.pos <- device[dev_rows, ]
device.cloud.pos <- device[-dev_rows, ]

#读取机场位置数据
airport <- read.table(airport.data.path, sep='\t',
    fileEncoding="UTF-8", comment.char="^")
a_rows <- grep('CN', airport$V8)
airport.china <- airport[a_rows, ]
airport.cnt <- nrow(airport.china)

#读取信号位置信息
signal <- read.table(signal.data.path, sep='\001',
    fileEncoding="UTF-8")
dev_rows <- grep('DEV_', signal$V1)
signal.profession <- signal[dev_rows, ]
signal.cloud <- signal[-dev_rows, ]

jwd.data <- read.table(area_jwd.data.path, sep=' ',
    fileEncoding="UTF-8")
jwd.cnt <- nrow(jwd.data)

#读取航班数据
flight <- read.table(flight.data.path, sep='\t', fileEncoding="UTF-8",
    comment.char="^", nrows=1)

#读取地图数据
bount <- readShapePoly("/root/tianyan/map_data/BOUNT_poly.shp")
bount.data <-  fortify(bount)
mymap <- (ggplot(data=bount.data)
    + geom_polygon(aes(x=long, y=lat, group=id), size=1, fill = NA,
        colour="gray")
    + theme(panel.background=element_blank(), legend.position="none"))
prov_bount <- readShapePoly("/root/tianyan/map_data/bou2_4p.shp")

#计算文本注解位置
x_pos <- mean(range(bount.data$long))
y_pos <- max(range(bount.data$lat))

#各图层叠加
p <- (mymap + coord_map()
    + geom_polygon(data=fortify(prov_bount),
        aes(x=long, y=lat, group=id), size=2, colour="black", fill=NA))
p <- (p
    + geom_point(data=signal.cloud, size=1, aes(x=V2, y=V3, colour=V1), 
        alpha=I(1/2))
    + geom_point(data=signal.profession, size=1, aes(x=V2, y=V3),
        colour="black", alpha=I(1/2))
    + geom_point(data=airport.china, size=14, aes(x=V11, y=V12), shape=18,
        colour="red", alpha=I(1))
    + geom_point(data=device, size=5, aes(x=V3, y=V4), colour="blue", 
        alpha=I(1))
    + annotate(rep("text", jwd.cnt), size=3, x=jwd.data$V4, y=jwd.data$V5,
         label=jwd.data$V3)
    + annotate(rep("text", airport.cnt), x=airport.china$V11,
        y=airport.china$V12-0.1, size=rep(5, airport.cnt),
        label=paste(airport.china$V4, airport.china$V2, seq=""))
    + annotate("text", x=x_pos, y=y_pos, size=100,
        label=paste("设备_机场_信号可视化_", day, sep="")))
print(p)
q()
