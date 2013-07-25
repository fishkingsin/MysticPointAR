#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxQCAR.h"
#define NUM_STRIP 20
#define LOC_LENGTH 30
#define LENGTH LOC_LENGTH*2
class Strips{

public:
    void setup()
    {
        for (int j=0; j<NUM_STRIP; j++)
        {
            pos[j].set(ofRandom(0, ofGetWidth()),ofRandom(0,ofGetHeight()),0);
            vec[j].set(0,0,0);
            acc[j].set(ofRandom(-1,1),ofRandom(-1,1),0);
            age[j] = 1;
            float h = ofRandom(100,150);
            for (int i=0; i<LENGTH; i++)
            {
                int index = i+(j*LENGTH);
                strip[index].set(ofGetWidth()*0.5,ofGetHeight()*0.5,0);
                float brightness = sinf(PI*float((i*0.5)*1.f/LENGTH*0.5f))*125;
                color[index].set(ofColor::fromHsb(h,255, 255,brightness));
            }
            
            for (int i=0; i<LOC_LENGTH; i++)
            {
                int index = i+(j*LOC_LENGTH);
                loc[index].set(0,0,0);
            }
            
            
        }
        total = NUM_STRIP*LENGTH;
        vbo.setVertexData(strip, total, GL_DYNAMIC_DRAW);
        vbo.setColorData(color, total, GL_DYNAMIC_DRAW);
        count = 0;
    }
    void update()
    {
        float t = (ofGetElapsedTimef()) * 0.9f;
        float div = 250.0;
        for (int j=0; j<NUM_STRIP; j++)
        {
            if(age[j]>0)
            {
                ofVec3f _vec(ofSignedNoise(t, pos[j].y/div, pos[j].z/div),
                             ofSignedNoise(pos[j].x/div, t, pos[j].z/div),
                             0);
                _vec *=  ofGetLastFrameTime()*50;
                vec[j]+=_vec;
                vec[j]+=acc[j];
                vec[j]*=0.9;
                ofVec3f Off;
                float radius = 20;
                for (int i=LOC_LENGTH-1; i>=1; i--)
                {
                    int index = i+(j*LOC_LENGTH);
                    loc[index].set(loc[index-1]);
                }
                for (int i=0; i<LOC_LENGTH; i++)
                {
                    int index = i+(j*LOC_LENGTH);
                    int index2 = (i*2)+(j*LENGTH);
                    
                    
                    radius = sinf(PI*float(i*1.f/LOC_LENGTH))*15;
                    {
                        ofVec3f perp0 = loc[index] - loc[index+1];
                        ofVec3f perp1 = perp0.getCrossed( ofVec3f( 0, 0, 1 ) ).getNormalized();
                        ofVec3f perp2 = perp0.getCrossed( perp1 ).getNormalized();
                        perp1 = perp0.getCrossed( perp2 ).getNormalized();
                        Off.x        = perp1.x * radius*age[j];
                        Off.y       = perp1.y * radius*age[j];
                        Off.z        = perp1.z * radius*age[j];
                        
                        strip[(index2)]=loc[index]-Off;
                        
                        strip[(index2+1)]=loc[index]+Off;
                    }
                }
                loc[j*LOC_LENGTH] = pos[j];
                pos[j]+=vec[j];
                age[j]-=0.02;
            }
            else
            {
                for (int i=0; i<LOC_LENGTH; i++)
                {
                    int index = i+(j*LOC_LENGTH);
                    loc[index].set(pos[j]);
                    int index2 = (i*2)+(j*LENGTH);
                    strip[(index2)]=loc[index];
                    
                    strip[(index2+1)]=loc[index];
                }
            }
            
            
        }
    }
    void draw()
    {
        glEnable(GL_DEPTH_TEST);
        vbo.bind();
        vbo.updateVertexData(strip, total);
        vbo.updateColorData(color, total);
        
        
        for (int j=0; j<NUM_STRIP; j++)
            
        {
            int index = j * LENGTH;
            
            vbo.draw(GL_TRIANGLE_STRIP, index,LENGTH);
            
        }
        
        
        vbo.unbind();
        glDisable(GL_DEPTH_TEST);
    }
    void fireStrip(float x, float y,float px , float py)
    {
        //    int ran = ofRandom(1,3);
        //    for(int j = 0 ; j < ran ; j++)
        {
            count++;
            
            count%=NUM_STRIP;

            pos[count].set(x+sin(ofRandomf()*TWO_PI)*ofRandom(-50,50), y+cos(ofRandomf()*TWO_PI)*ofRandom(-50,50));
            vec[count].set(x-px,y-py,ofRandom(30,50));
            vec[count]*=2;
            acc[count].set((x-pos[count].x)*0.01, (y-pos[count].y)*0.01);
            age[count] = 1;
            
            for (int i=0; i<LOC_LENGTH; i++)
            {
                int index = i+(count*LOC_LENGTH);
                loc[index].set(pos[count]);
                int index2 = (i*2)+(count*LENGTH);
                strip[(index2)]=loc[index];
                
                strip[(index2+1)]=loc[index];
                
                
            }
            
            
            
        }
    }
    ofVbo vbo;
    ofVec3f pos[NUM_STRIP];
    ofVec3f acc[NUM_STRIP];
    ofVec3f vec[NUM_STRIP];
    float age[NUM_STRIP];
    ofVec3f strip[NUM_STRIP*LENGTH];
    ofVec3f loc[NUM_STRIP*LOC_LENGTH];
	ofFloatColor color[NUM_STRIP*LENGTH];
    int total;
    int count;

};

class testApp : public ofxiPhoneApp{
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
//    ofPoint touchPoint;
    
    ofImage cameraImage;
    ofImage eyeImage;
    
    Strips strips;
};


