#! /usr/bin/python
# -*- coding: utf-8 -*-

# Import the libraries to use
import numpy as np
import cv2
import matplotlib.pyplot as plt
import pandas as pd
from PIL import Image

# Path of the pictures with low resolution 
path_lowres = './Church_data_set/church_image-raw/'
	       +'church_image_lowres/'

# Parameters for Shi-Tomasi corner detection
feature_params = dict( maxCorners = 400, # A max. of 400 strong 
					 # corners
                       qualityLevel = 0.3,
                       minDistance = 7,
                       blockSize = 7 )
# Parameters for Lucas-Kanade optical flow
lk_params = dict( winSize  = (18,18),
                  maxLevel = 2,
                  criteria = (cv2.TERM_CRITERIA_EPS 
			      | cv2.TERM_CRITERIA_COUNT
       	  		      , 10, 0.03))
# Create some random colors
color = np.random.randint(0,255,(100,3))

# Take first frame image and find corners in church data set
old_frame = cv2.imread(path_lowres+'church_image-raw_0000'
				   +'_lowres.jpg',1)
old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, 
				**feature_params)
st = np.array([[1]]*len(p0))
# Create a data frame with the entries of the point
df_church = pd.DataFrame({'x1' : p0[st==1][:,0], 
			  'y1' : p0[st==1][:,1]})
# Vector to track the number of points to track 
lengths_church = [len(p0)]
# Create a mask image for drawing purposes
mask = np.zeros_like(old_frame)

# For loop to track those points with Lucas-Kanade
for i in range(0,100):
    if i < 10: 
        frame = cv2.imread(path_lowres+'church_image-raw_000'
			   +str(i)+'_lowres.jpg')
        frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # calculate optical flow
        p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray,
	              frame_gray, p0, None, **lk_params)
        # Select good points
        good_new = p1[st==1]
        good_old = p0[st==1]
        # append new length to lengths
        lengths_church.append(len(p1))
        
        # Adding the new points to the dataframe
        df_church_new = pd.DataFrame({
		     'x'+str(i+2) : [np.nan]*len(df_church.x1),
                      'y'+str(i+2) : [np.nan]*len(df_church.x1)})
        notnull = ~pd.isnull(df_church['x'+str(i+1)])
        df_church_new1 = df_church_new[notnull]
        id=df_church_new1[[sti[0]==1 for sti in st]].index
        df_church_new1['x'+str(i+2)][[sti[0]==1 for sti in st]] 
			=  pd.Series(p1[st==1][:,0],index = id)
        df_church_new1['y'+str(i+2)][[sti[0]==1 for sti in st]]
			 =  pd.Series(p1[st==1][:,1],index = id)
        df_church_new[notnull] = df_church_new1
        df_church=df_church.join(df_church_new)
        
        # draw the tracks
        for j,(new,old) in enumerate(zip(good_new,good_old)):
            a,b = new.ravel()
            c,d = old.ravel()
            mask = cv2.line(mask, (a,b),(c,d), color[j%100].tolist()
				, 2)
            frame = cv2.circle(frame,(a,b),5,color[j%100].tolist()
				, -1)
        img = cv2.add(frame,mask)
        #cv2.imshow('frame',img)

        # Now update the previous frame and previous points
        old_gray = frame_gray.copy()
        p0 = good_new.reshape(-1,1,2)
    else:
        if i < 100:
            frame = cv2.imread(path_lowres
		    +'church_image-raw_00'+str(i)+'_lowres.jpg')
            frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            # calculate optical flow
            p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, 
                          p0, None, **lk_params)
            # Select good points
            good_new = p1[st==1]
            good_old = p0[st==1]
            # append new length to lengths
            lengths_church.append(len(p1))
            
            # Adding the new points to the dataframe
            df_church_new = pd.DataFrame({'x'+str(i+2) : [np.nan]
		*len(df_church.x1), 'y'+str(i+2) : 
		 [np.nan]*len(df_church.x1)})
            notnull = ~pd.isnull(df_church['x'+str(i+1)])
            df_church_new1 = df_church_new[notnull]
            id=df_church_new1[[sti[0]==1 for sti in st]].index
            df_church_new1['x'+str(i+2)][[sti[0]==1 for sti in st]] 
	     =  pd.Series(p1[st==1][:,0],index = id)
            df_church_new1['y'+str(i+2)][[sti[0]==1 for sti in st]] 
	     = pd.Series(p1[st==1][:,1],index = id)
            df_church_new[notnull] = df_church_new1
            df_church=df_church.join(df_church_new)
        
            # draw the tracks
            for j,(new,old) in enumerate(zip(good_new,good_old)):
                a,b = new.ravel()
                c,d = old.ravel()
                mask = cv2.line(mask, (a,b),(c,d), 
				color[j%100].tolist(), 2)
                frame = cv2.circle(frame,(a,b),5,
				color[j%100].tolist(),-1)
            img = cv2.add(frame,mask)
            #cv2.imshow('frame',img)

            # Now update the previous frame and previous points
            old_gray = frame_gray.copy()
            p0 = good_new.reshape(-1,1,2)
        else:
            frame = cv2.imread(path_lowres+'church_image-raw_0100_'
						+'lowres.jpg')
            frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            # calculate optical flow
            p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, 
	                  p0, None, **lk_params)
            # Select good points
            good_new = p1[st==1]
            good_old = p0[st==1]
            # append new length to lengths
            lengths_church.append(len(p1))
            
            # Adding the new points to the dataframe
            df_church_new = pd.DataFrame({'x'+str(i+2) : [np.nan]
	      *len(df_church.x1), 'y'+str(i+2) : [np.nan]*len(df_church.x1)})
            notnull = ~pd.isnull(df_church['x'+str(i+1)])
            df_church_new1 = df_church_new[notnull]
            id=df_church_new1[[sti[0]==1 for sti in st]].index
            df_church_new1['x'+str(i+2)][[sti[0]==1 for sti in st]]
	    =  pd.Series(p1[st==1][:,0],index = id)
            df_church_new1['y'+str(i+2)][[sti[0]==1 for sti in st]] 
	    = pd.Series(p1[st==1][:,1],index = id)
            df_church_new[notnull] = df_church_new1
            df_church=df_church.join(df_church_new)
            
            # draw the tracks
            for j,(new,old) in enumerate(zip(good_new,good_old)):
                a,b = new.ravel()
                c,d = old.ravel()
                mask = cv2.line(mask, (a,b),(c,d),
		                color[j%100].tolist(), 2)
                frame = cv2.circle(frame,(a,b),5,
			          color[j%100].tolist(),-1)
            img = cv2.add(frame,mask)
            img = cv2.add(frame,mask)
            #cv2.imshow('frame',img)

            # Now update the previous frame and previous points
            old_gray = frame_gray.copy()
            p0 = good_new.reshape(-1,1,2)
            
cv2.destroyAllWindows()

# Save in a csv file
df_church.to_csv('church_tracking.csv')

# Plot it
plt.rcParams["figure.figsize"] = [12,9]
plt.imshow(img,cmap='gray')
plt.show()
