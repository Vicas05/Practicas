# MAP WITH ALL EXREMOPHILES LOCATIONS AND LOCATIONS TO ADD ---------------------

	LOC<-read.xlsx(xlsxFile="/home/rafa/WORKDIRECTORY/MADRID/EXTREMOPHILES/EXTREMOPHILESreview/EXTREMOPHILES_REFINED_20MAR2026.xlsx",sheet="Summary",startRow=6,colNames=TRUE,rowNames=FALSE,rows=c(6:4018),cols=c(6:10),check.names=FALSE,na.strings="NA")

	# Projecton proj4string for Winkel Tripel
		wintri<-"+proj=wintri" 	
	# Getting world map	
		worldmap<-getMap(resolution="high")
    	world_sf<-st_as_sf(worldmap)
	# Reprojecting the map
		st_crs(world_sf)<-4326					# This a trick to avoid GDAL/PROJ.4 version ERROR
		world_sf<-st_transform(world_sf,crs=4326)
		WorldWintri<-st_transform_proj(world_sf, crs=wintri)   # Getting the map with the Winkel Tripel projection
		
		# Getting Graticulate
		graticule <-st_graticule(lat = c(-89.9, seq(-80, 80, 20), 89.9))
	  grat_wintri<-st_transform_proj(graticule,crs = wintri)

	# turn into correctly projected sf collection
  	 	lats <- c(90:-90, -90:90, 90)
		longs <- c(rep(c(180, -180), each = 181), 180)
		WorldBG<-st_sfc(st_polygon(list(cbind(longs,lats))),crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
		WorldBG<-st_transform_proj(st_sf(WorldBG),crs=wintri)

	## Additional map information from natural earth packages
	    GlaciatedAreas<-st_read("/home/rafa/WORKDIRECTORY/SCRIPTS/R/MAPs/ne_110m_glaciated_areas.shp")
	    GlaciatedAreasW<-st_transform_proj(GlaciatedAreas,crs = wintri)

     #Transforming xlim and ylim limits coordinates (the whole planet in this case)
	    Limits<-data.frame(c(-180,180),c(-90,90))
	    colnames(Limits)<-c("lon","lat")
	  	Limits<-SpatialPointsDataFrame(coords = Limits,data=Limits, proj4string = CRS("+proj=longlat"))
	  	Limits<-as.data.frame(coordinates(spTransform(Limits,CRSobj=CRS(wintri))))
	  	MedSeaLimits<-data.frame(c(-6.5,39),c(29,46))
	  	colnames(MedSeaLimits)<-c("lon","lat")
	  	MedSeaLimits<-SpatialPointsDataFrame(coords = MedSeaLimits,data=MedSeaLimits, proj4string = CRS("+proj=longlat"))
	  	MedSeaLimits<-as.data.frame(coordinates(spTransform(MedSeaLimits,CRSobj=CRS(wintri))))	  	
	  	VicLandLimits<-data.frame(c(160,165),c(-78,-73))
	  	colnames(VicLandLimits)<-c("lon","lat")
	  	VicLandLimits<-SpatialPointsDataFrame(coords = VicLandLimits,data=VicLandLimits, proj4string = CRS("+proj=longlat"))
	  	VicLandLimits<-as.data.frame(coordinates(spTransform(VicLandLimits,CRSobj=CRS(wintri))))	  		

	# Transforming locations coordinates
   		lon<-as.numeric(LOC[,3])
	    lat<-as.numeric(LOC[,2])  
	    Coords<-as.data.frame(cbind(lon,lat))
	    colnames(Coords)<-c("lon","lat")
	    Coords<-Coords[complete.cases(Coords),]  

	    CoordsT<-SpatialPointsDataFrame(coords = Coords,data=Coords, proj4string = CRS("+proj=longlat"))
	    CoordsT<-as.data.frame(coordinates(spTransform(CoordsT,CRSobj=CRS(wintri))))
    
    ## Points settings for cex range and shape
	    h<-1500
    	w<-3900
    	r<-300
	   	PchRange<-c(1,25,50,100,500,1000)
    	PchCex<-seq(0.75,3.5,length.out=length(PchRange))
    	names(PchCex)<-c("1",">25",">50",">100",">500",">1000")

  ## Plotting the map
    	png("GRAPHICS/Extremophiles.Map.png",height=h,width=w,res=r,bg="transparent")
    		# par(mar=c(0,0,0,0))
    		par(mar=c(0,0,0,15))
  			plot(st_geometry(WorldBG),xlim=Limits[,1],ylim=Limits[,2],border="skyblue2",col="skyblue2")
				par(new=TRUE)
				plot(st_geometry(WorldWintri),xlim=Limits[,1],ylim=Limits[,2],col="burlywood1",border="white",axes=FALSE)
				par(new=TRUE)
	      		plot(st_geometry(GlaciatedAreasW),xlim=Limits[,1],ylim=Limits[,2],col="white",border="white") 
				par(new=TRUE)
				 # plot(st_geometry(grat_wintri))
				plot(st_geometry(WorldWintri),xlim=Limits[,1],ylim=Limits[,2],graticule=grat_wintri,col_graticule="grey90",border="white",lty=3,lwd=1)
				# Plotting points for total frequency
				par(new=TRUE)
				for(r in 1:nrow(LOC)){
					v<-LOC[r,"Frequency"]
					points(CoordsT[r,1],CoordsT[r,2],pch=21,xpd=TRUE,col="slateblue4",bg=rgb(t(col2rgb("slateblue4")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)])
				}
				# Plotting points for validated genomes	
				for(r in 1:nrow(LOC)){
					v<-LOC[r,"Validated"]
					if(v>0){
						# print(v)
						points(CoordsT[r,1],CoordsT[r,2],pch=22,xpd=TRUE,col="indianred3",bg=rgb(t(col2rgb("indianred3")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)],lwd=0.5)
					}
				}	

				# # Pch legend
				par(new=TRUE)
				plot(NA,NA,axes=FALSE,xlab="",ylab="",xlim=c(0,10),ylim=c(0,10))
				yi<-6.5
				text(11,4.5,labels="Nr of\ngenomes",adj=c(1,0),xpd=TRUE,font=2,cex=1.2)
				for(p in 1:length(PchRange)){
					points(11.25,yi,pch=21,cex=PchCex[p],lwd=2,xpd=TRUE,col="black",bg=lighten("black",0.5))
					text(11.4,yi,labels=names(PchCex[p]),adj=c(0,0.5),cex=1.2,font=2,xpd=TRUE)
					yi<-yi-0.55
				}
				# Type of point
					points(x=c(0,0),y=c(yi-1,yi-1.5),cex=1.5,pch=c(21,22),col=c("slateblue4","indianred3"),bg=c(rgb(t(col2rgb("slateblue4")),alpha=100,maxColorValue=255),rgb(t(col2rgb("indianred3")),alpha=100,maxColorValue=255)),lwd=2,xpd=TRUE)
					text(x=0.1,y=c(yi-1,yi-1.5),labels=c("Total: 20,616","Validated: 2,451"),font=2,cex=1.2,xpd=TRUE,adj=c(0,0.5))

				lines(c(10.4,10.4),c(-1,11),col="red",xpd=TRUE)

		   		## Zoom to Mediterranean Sea
		   			par(mar=c(17,45,1,1),new=TRUE)
		   			plot(NA,NA,xlim=c(0,10),ylim=c(0,10),axes=FALSE,ylab="",xlab="")
		   			arrows(0,0,-9,-1.5,code=0,lty=3,xpd=TRUE,lwd=1.5)
		   			arrows(0,10,-9.25,2.3,code=0,lty=3,xpd=TRUE,lwd=1.5)	   			
		   			par(new=TRUE)
		   			plot(st_geometry(WorldBG),xlim=MedSeaLimits[,1],ylim=MedSeaLimits[,2],border="skyblue2",col="skyblue2",axes=FALSE)
					par(new=TRUE)
					plot(st_geometry(WorldWintri[,1]),xlim=MedSeaLimits[,1],ylim=MedSeaLimits[,2],col="burlywood1",border="white",axes=FALSE)
					par(new=TRUE)
					plot(st_geometry(WorldWintri),xlim=MedSeaLimits[,1],ylim=MedSeaLimits[,2],graticule=grat_wintri,border="white",axes=FALSE)
					# Plotting points for total frequency
					par(new=TRUE)
					for(r in 1:nrow(LOC)){
						v<-LOC[r,"Frequency"]
						points(CoordsT[r,1],CoordsT[r,2],pch=21,xpd=FALSE,col="slateblue4",bg=rgb(t(col2rgb("slateblue4")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)])
					}
					# Plotting points for validated genomes	
					for(r in 1:nrow(LOC)){
						v<-LOC[r,"Validated"]
						if(v>0){
							# print(v)
							points(CoordsT[r,1],CoordsT[r,2],pch=22,xpd=FALSE,col="indianred3",bg=rgb(t(col2rgb("indianred3")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)],lwd=0.5)
						}
					}

		   		## Zoom to Antarctica
		   			par(mar=c(1,47,17,1),new=TRUE)
		   			plot(NA,NA,xlim=c(0,10),ylim=c(0,10),axes=FALSE,ylab="",xlab="")
		   			arrows(0,0,-5.5,1,code=0,lty=3,xpd=TRUE,lwd=1.5)
		   			arrows(0,10,-5.6,2.2,code=0,lty=3,xpd=TRUE,lwd=1.5)	
		   			par(new=TRUE)
		   			plot(st_geometry(WorldBG),xlim=VicLandLimits[,1],ylim=VicLandLimits[,2],border="skyblue2",col="skyblue2",axes=FALSE)
					par(new=TRUE)
					plot(st_geometry(WorldWintri[,1]),xlim=VicLandLimits[,1],ylim=VicLandLimits[,2],col="burlywood1",border="white",axes=FALSE)
					par(new=TRUE)
					plot(st_geometry(WorldWintri),xlim=VicLandLimits[,1],ylim=VicLandLimits[,2],graticule=grat_wintri,border="white",axes=FALSE)
					# Plotting points for total frequency
					par(new=TRUE)
					for(r in 1:nrow(LOC)){
						v<-LOC[r,"Frequency"]
						points(CoordsT[r,1],CoordsT[r,2],pch=21,xpd=FALSE,col="slateblue4",bg=rgb(t(col2rgb("slateblue4")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)])
					}
					# Plotting points for validated genomes	
					for(r in 1:nrow(LOC)){
						v<-LOC[r,"Validated"]
						if(v>0){
							points(CoordsT[r,1],CoordsT[r,2],pch=22,xpd=FALSE,col="indianred3",bg=rgb(t(col2rgb("indianred3")),alpha=100,maxColorValue=255),cex=PchCex[sum(PchRange<=v)],lwd=0.5)
						}
					}				
    	dev.off()
