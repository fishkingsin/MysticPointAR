#include "testApp.h"
int rotation = 0;
int interval = 0;
bool bPressed;
//--------------------------------------------------------------
void testApp::setup(){
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//If you want a landscape oreintation
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
	ofBackground(127,127,127);
    
    ofxQCAR * qcar = ofxQCAR::getInstance();
    qcar->addTarget("Disney.xml", "Disney.xml");
    qcar->autoFocusOn();
    qcar->setCameraPixelsFlag(true);
    qcar->setup();
    
    eyeImage.loadImage("eye.png");
    strips.setup();
}

//--------------------------------------------------------------
void testApp::update(){
    ofxQCAR * qcar = ofxQCAR::getInstance();
    
    qcar->update();
    if(qcar->hasFoundMarker()) {
        
        strips.update();
        int diff = ofGetElapsedTimeMillis()-interval;
        if(diff>500)
        {
            int i = ofRandom(0,5);
            while(i>0)
            {
                strips.fireStrip(0, 0, ofRandom(-10,10), ofRandom(-10,10));
                i--;
            }
            interval = ofGetElapsedTimeMillis();
        }
    }
}

//--------------------------------------------------------------
void testApp::draw(){
	ofxQCAR * qcar = ofxQCAR::getInstance();
    qcar->draw();
    
    //    bool bPressed;
    //    bPressed = touchPoint.x >= 0 && touchPoint.y >= 0;
    
    if(qcar->hasFoundMarker()) {
        
        glDisable(GL_DEPTH_TEST);
        ofEnableBlendMode(OF_BLENDMODE_ALPHA);
        ofSetLineWidth(3);
        
        bool bInside = false;
        if(bPressed) {
            vector<ofPoint> markerPoly;
            markerPoly.push_back(qcar->getMarkerCorner((ofxQCAR_MarkerCorner)0));
            markerPoly.push_back(qcar->getMarkerCorner((ofxQCAR_MarkerCorner)1));
            markerPoly.push_back(qcar->getMarkerCorner((ofxQCAR_MarkerCorner)2));
            markerPoly.push_back(qcar->getMarkerCorner((ofxQCAR_MarkerCorner)3));
            //            bInside = ofInsidePoly(touchPoint, markerPoly);
            
            
            ofSetColor(ofColor(255, 0, 255, bInside ? 150 : 50));
            qcar->drawMarkerRect();
            
            ofSetColor(ofColor::yellow);
            qcar->drawMarkerBounds();
            ofSetColor(ofColor::cyan);
            qcar->drawMarkerCenter();
            qcar->drawMarkerCorners();
        }
        ofSetColor(ofColor::white);
        ofSetLineWidth(1);
        
        glEnable(GL_DEPTH_TEST);
        ofEnableNormalizedTexCoords();
        
        //        teapotImage.getTextureReference().bind();
        //        ofDrawTeapot(qcar->getProjectionMatrix(), qcar->getModelViewMatrix(), 3);
        //        teapotImage.getTextureReference().unbind();
        
        
        glEnable( GL_DEPTH_TEST );
        //        glEnable( GL_CULL_FACE );
        
        glPushMatrix();
        glTranslatef( ofGetWidth() * 0.5, ofGetHeight() * 0.5, 0 );
        
        {
            glEnableClientState( GL_TEXTURE_COORD_ARRAY );
            glEnableClientState( GL_VERTEX_ARRAY );
            glEnableClientState( GL_NORMAL_ARRAY );
            
            glMatrixMode(GL_PROJECTION);
            glLoadMatrixf(qcar->getProjectionMatrix().getPtr() );
            
            glMatrixMode( GL_MODELVIEW );
            glLoadMatrixf( qcar->getModelViewMatrix().getPtr() );
            
            
            
            glPushMatrix();
            
            
            
            glTranslatef(6, -19, 0);
            //glScalef(2.421f, 2.421f, 1);
            rotation += 1;
            glRotatef(rotation, 0, 0, 1);
            eyeImage.draw(-eyeImage.getWidth()*0.5, eyeImage.getHeight()*0.5 ,eyeImage.getWidth(), -eyeImage.getHeight());
            glPopMatrix();
            
            strips.draw();
            glDisableClientState( GL_TEXTURE_COORD_ARRAY );
            glDisableClientState( GL_VERTEX_ARRAY );
            glDisableClientState( GL_NORMAL_ARRAY );
        }
        glPopMatrix();
        
        glDisable( GL_DEPTH_TEST );
        //        glDisable( GL_CULL_FACE );
        
        ofSetupScreen();
        
        ofDisableNormalizedTexCoords();
    }
    
    glEnable(GL_DEPTH_TEST);
    
    /**
     *  access to camera pixels.
     */
    //    int cameraW = qcar->getCameraWidth();
    //    int cameraH = qcar->getCameraHeight();
    //    unsigned char * cameraPixels = qcar->getCameraPixels();
    //    if(cameraW > 0 && cameraH > 0 && cameraPixels != NULL) {
    //        if(cameraImage.isAllocated() == false ) {
    //            cameraImage.allocate(cameraW, cameraH, OF_IMAGE_GRAYSCALE);
    //        }
    //        cameraImage.setFromPixels(cameraPixels, cameraW, cameraH, OF_IMAGE_GRAYSCALE);
    //        if(qcar->getOrientation() == OFX_QCAR_ORIENTATION_PORTRAIT) {
    //            cameraImage.rotate90(1);
    //        } else if(qcar->getOrientation() == OFX_QCAR_ORIENTATION_LANDSCAPE) {
    //            cameraImage.mirror(true, true);
    //        }
    //
    //        cameraW = cameraImage.getWidth() * 0.5;
    //        cameraH = cameraImage.getHeight() * 0.5;
    //        int cameraX = 0;
    //        int cameraY = ofGetHeight() - cameraH;
    //        cameraImage.draw(cameraX, cameraY, cameraW, cameraH);
    //
    //        ofPushStyle();
    //        ofSetColor(ofColor::white);
    //        ofNoFill();
    //        ofSetLineWidth(3);
    //        ofRect(cameraX, cameraY, cameraW, cameraH);
    //        ofPopStyle();
    //    }
    //
    //    if(bPressed) {
    //        ofSetColor(ofColor::red);
    //        ofDrawBitmapString("touch x = " + ofToString((int)touchPoint.x), 20, 200);
    //        ofDrawBitmapString("touch y = " + ofToString((int)touchPoint.y), 20, 220);
    //    }
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    bPressed = true;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    bPressed = false;
    rotation = 0;
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}

