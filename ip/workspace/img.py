#!/usr/bin/python

print "P3"

hres = 1280
vres = 720

hres_threshold = 300
vres_threshold = 20

print hres, vres
print 255

for y in range(0, vres):
  for x in range(0, hres):
    if y < vres_threshold or y == vres_threshold and x < hres_threshold:
    # white
      print 255, 255, 255
    else:
    # gradient of RGB
      print y % 256,
      print (x * 25 / 256) % 256,
      print x % 256,
  print
