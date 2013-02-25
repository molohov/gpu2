#!/usr/bin/python

print "P3"

hres = 1280
vres = 720

print hres, vres
print 255

for y in range(0, vres):
  for x in range(0, hres):
    print y % 256,
    print (x * 25 / 256) % 256,
    print x % 256,
  print
