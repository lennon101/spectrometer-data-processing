import utm
import simplekml
import csv
from polycircles import polycircles

fileName = 'kmlPackage.csv'

def printCSV(fileName):
    with open(fileName, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            print row
    csvfile.close()

def getCSVArray(fileName):
    csvArray = []
    with open(fileName, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            csvArray.append(row)
    csvfile.close()
    return csvArray

printCSV(fileName)    

kml = simplekml.Kml()
kmlArray = getCSVArray(fileName)

for row in kmlArray:
    kmlName = "sample: " + row[0]
    lat = float(row[1])
    lon = float(row[2])
    dn = float(row[3])
    de = float(row[4])
    altitude = float(row[5])
    radius = float(row[6])
    NDVI = row[7]
    EVI = row[8]

    #utm.from_latlon(LATITUDE, LONGITUDE).
    utmValue = utm.from_latlon(lat, lon)
    #returns (EASTING, NORTHING, ZONE NUMBER, ZONE LETTER).

    newUtmLat = utmValue[0] + dn
    newUtmLon = utmValue[1] + de

    #utm.to_latlon(EASTING, NORTHING, ZONE NUMBER, ZONE LETTER).
    latLon = utm.to_latlon(newUtmLat, newUtmLon, utmValue[2], utmValue[3])
    #returns (LATITUDE, LONGITUDE).

    data = "Altitude sample taken at: " + str(altitude) + "\nNDVI: " + NDVI + "\nEVI: " + EVI
    # lon, lat, optional height
    kml.newpoint(name=kmlName, coords=[(latLon[1],latLon[0])], description=data)

    polycircle = polycircles.Polycircle(latitude= latLon[0],longitude= latLon[1],radius=radius, number_of_vertices=36)
    pol = kml.newpolygon(name=kmlName,outerboundaryis=polycircle.to_kml())
    pol.style.polystyle.color = simplekml.Color.changealphaint(200, simplekml.Color.green)
    

print kml.kml()

kml.save("test.kml")