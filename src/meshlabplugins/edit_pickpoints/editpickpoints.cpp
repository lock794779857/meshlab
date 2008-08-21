/*  A class implementing Meshlab's Edit interface that is for picking points in 3D
 * 
 * 
 * @author Oscar Barney
 */

#include <QtGui>

#include <GL/glew.h>

#include "editpickpoints.h"
#include <meshlab/mainwindow.h>

#include <wrap/gl/picking.h>
#include <wrap/gl/pick.h>

#include <math.h>

using namespace vcg;

#define PI 3.14159265


EditPickPointsPlugin::EditPickPointsPlugin(){
	actionList << new QAction(QIcon(":/images/pickpoints.png"), pickPointsActionName, this);
	
	foreach(QAction *editAction, actionList)
	    editAction->setCheckable(true);
	
	//initialize to false so we dont end up collection some weird point in the beginning
	addPoint = false;
	movePoint = false;
	
	pickPointsDialog = 0;
	currentModel = 0;
}

//Constants

//name of the actions
const char* EditPickPointsPlugin::pickPointsActionName = "PickPoints";



//just returns the action list
QList<QAction *> EditPickPointsPlugin::actions() const {
	return actionList;
}

const QString EditPickPointsPlugin::Info(QAction *action) 
{
	if( action->text() != tr(pickPointsActionName) )
		assert (0);
  	
	return tr("Pick and save 3D points on the mesh");
}

const PluginInfo &EditPickPointsPlugin::Info() 
{
	static PluginInfo ai; 
	ai.Date=tr(__DATE__);
	ai.Version = tr("1.0");
	ai.Author = ("Oscar Barney");
	return ai;
} 

//called
void EditPickPointsPlugin::Decorate(QAction * /*ac*/, MeshModel &mm, GLArea *gla)
{
	//qDebug() << "Decorate " << mm.fileName.c_str() << " ...";
	
	if(gla != glArea){
		qDebug() << "GLarea is different!!! ";
	}
	
	
	//make sure we picking points on the right meshes!
	if(&mm != currentModel){
		//now that were are ending tell the dialog to save any points it has to metadata
		pickPointsDialog->savePointsToMetaData();
		
		//set the new mesh model
		pickPointsDialog->setCurrentMeshModel(&mm, gla);
		currentModel = &mm;
	}
	
	//We have to calculate the position here because it doesnt work in the mouseEvent functions for some reason
	Point3f pickedPoint;
	if (movePoint && Pick<Point3f>(currentMousePosition.x(),gla->height()-currentMousePosition.y(),pickedPoint)){
			qDebug("Found point for move %i %i -> %f %f %f",
					currentMousePosition.x(),
					currentMousePosition.y(),
					pickedPoint[0], pickedPoint[1], pickedPoint[2]);
			
			//let the dialog know that this was the pointed picked incase it wants the information
			pickPointsDialog->moveThisPoint(pickedPoint);
			
			movePoint = false;
	} else if(addPoint && Pick<Point3f>(currentMousePosition.x(),gla->height()-currentMousePosition.y(),pickedPoint)) 
	{
		qDebug("Found point for add %i %i -> %f %f %f",
				currentMousePosition.x(),
				currentMousePosition.y(),
				pickedPoint[0], pickedPoint[1], pickedPoint[2]);
	
		
		//find the normal of the face we just clicked
		CFaceO *face;
		bool result = GLPickTri<CMeshO>::PickNearestFace(currentMousePosition.x(),gla->height()-currentMousePosition.y(),
				mm.cm, face);
			
		if(!result){
			qDebug() << "find nearest face failed!";
		} else
		{
			CFaceO::NormalType faceNormal = face->N();
			//qDebug() << "found face normal: " << faceNormal[0] << faceNormal[1] << faceNormal[2];
			
			//if we didnt find a face then dont add the point because the user was probably 
			//clicking on another mesh opened inside the glarea
			pickPointsDialog->addPoint(pickedPoint, faceNormal);
		}
		
		addPoint = false;
		
	}
	
	drawPickedPoints(pickPointsDialog->getPickedPointTreeWidgetItemVector(), mm.cm.bbox);
}

void EditPickPointsPlugin::StartEdit(QAction * /*mode*/, MeshModel &mm, GLArea *gla )
{
	//qDebug() << "StartEdit Pick Points: " << mm.fileName.c_str() << " ...";
	
	//set this so redraw can use it
	glArea = gla;
	
	//Create GUI window if we dont already have one
	if(pickPointsDialog == 0)
	{
		pickPointsDialog = new PickPointsDialog(this, gla->window());
	}
	
	currentModel = &mm;
	
	//set the current mesh
	pickPointsDialog->setCurrentMeshModel(&mm, gla);
	
	//show the dialog
	pickPointsDialog->show();
	
}

void EditPickPointsPlugin::EndEdit(QAction * /*mode*/, MeshModel &mm, GLArea *gla)
{
	//qDebug() << "EndEdit Pick Points: " << mm.fileName.c_str() << " ...";
	// some cleaning at the end.
	
	//now that were are ending tell the dialog to save any points it has to metadata
	pickPointsDialog->savePointsToMetaData();

	//remove the dialog from the screen
	pickPointsDialog->hide();
}

void EditPickPointsPlugin::mousePressEvent(QAction *, QMouseEvent *event, MeshModel &mm, GLArea *gla )
{
	//qDebug() << "mouse press Pick Points: " << mm.fileName.c_str() << " ...";

	if(Qt::LeftButton | event->buttons()) 
	{
		gla->suspendedEditor = true;
		QCoreApplication::sendEvent(gla, event);
		gla->suspendedEditor = false;
	}
	
	if(Qt::RightButton == event->button() && 
			pickPointsDialog->getMode() == PickPointsDialog::MOVE_POINT){
	
		currentMousePosition = event->pos();
	
		//set flag that we need to add a new point
		movePoint = true;	
	}
}

void EditPickPointsPlugin::mouseMoveEvent(QAction *, QMouseEvent *event, MeshModel &mm, GLArea *gla ) 
{
	//qDebug() << "mousemove pick Points: " << mm.fileName.c_str() << " ...";
	
	if(Qt::LeftButton | event->buttons()) 
	{
		gla->suspendedEditor = true;
		QCoreApplication::sendEvent(gla, event);
		gla->suspendedEditor = false;
	}
	
	if(Qt::RightButton & event->buttons() && 
			pickPointsDialog->getMode() == PickPointsDialog::MOVE_POINT){
			
		//qDebug() << "mouse move left button and move mode: ";
		
		currentMousePosition = event->pos();
	
		//set flag that we need to add a new point
		addPoint = true;	
	}
}

void EditPickPointsPlugin::mouseReleaseEvent(QAction *,
		QMouseEvent *event, MeshModel &mm, GLArea * gla)
{
	//qDebug() << "mouseRelease Pick Points: " << mm.fileName.c_str() << " ...";
	
	if(Qt::LeftButton | event->buttons()) 
	{
		gla->suspendedEditor = true;
		QCoreApplication::sendEvent(gla, event);
		gla->suspendedEditor = false;
	}
	
	//only add points for the left button
	if(Qt::RightButton == event->button()){
	
		currentMousePosition = event->pos();
	
		//set flag that we need to add a new point
		addPoint = true;	
	}		
}

void EditPickPointsPlugin::drawPickedPoints(
		std::vector<PickedPointTreeWidgetItem*> &pointVector, vcg::Box3f &boundingBox)
{
	assert(glArea);
	
	vcg::Point3f size = boundingBox.Dim();
	//how we scale the object indicating the normal at each selected point
	float scaleFactor = (size[0]+size[1]+size[2])/90.0;

	//qDebug() << "scaleFactor: " << scaleFactor;
	
	glPushAttrib(GL_ENABLE_BIT | GL_POINT_BIT | GL_CURRENT_BIT | GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT | GL_COLOR_MATERIAL);
	
	// enable color tracking
	glEnable(GL_COLOR_MATERIAL);
	
	//draw the things that we always want to show, like the names 
	glDepthFunc(GL_ALWAYS);
	glDisable(GL_DEPTH_TEST); 
	glDepthMask(GL_FALSE);
	
	//set point attributes
	glPointSize(4.5);
	bool showNormal = pickPointsDialog->showNormal();
	bool showPin = pickPointsDialog->drawNormalAsPin();
	
	for(int i = 0; i < pointVector.size(); ++i)
	{
		PickedPointTreeWidgetItem * item = pointVector[i];
		//if the point has been set (it may not be if a template has been loaded)
		if(item->isActive()){
			Point3f point = item->getPoint();
			glColor(Color4b::Blue);
			glArea->renderText(point[0], point[1], point[2], QString(item->getName()) );
			
			//draw the dot if we arnt showing the normal or showing the normal as a line
			if(!showNormal || !showPin)
			{
				//glColor(Color4b::Blue);
				glBegin(GL_POINTS);
					glVertex(point);
				glEnd();
			}	
		}
	}


	//now draw the things that we want drawn if they are not ocluded 
	//we can see in bright red
	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST); 
	glDepthMask(GL_TRUE);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glMatrixMode(GL_MODELVIEW);
	
	Point3f yaxis;
	yaxis[0] = 0;
	yaxis[1] = 1;
	yaxis[2] = 0;
	
	for(int i = 0; i < pointVector.size(); ++i)
	{
		PickedPointTreeWidgetItem * item = pointVector[i];
		//if the point has been set (it may not be if a template has been loaded)
		if(item->isActive()){
			Point3f point = item->getPoint();
			
			if(showNormal)
			{
				Point3f normal = item->getNormal();
			
				if(showPin)
				{
					//dot product
					float angle = (Angle(normal,yaxis) * 180.0 / PI);
					
					//cross product
					Point3f axis = yaxis^normal;
					//qDebug() << "angle: " << angle << " x" << axis[0] << " y" << axis[1] << " z" << axis[2];
	
					//green and a little clear
					glColor4f(0.0f, 1.0f, 0.0f, 0.75f);
					//glColor(Color4b::Green);
		
					glPushMatrix();
					
					//move the pin to where it needs to be
					glTranslatef(point[0], point[1], point[2]);
					glRotatef(angle, axis[0], axis[1], axis[2]);
					glScalef(0.2*scaleFactor, 1.5*scaleFactor, 0.2*scaleFactor);
					
					glBegin(GL_TRIANGLES);
						
						//front
						glNormal3f(0, -1, 1);
						glVertex3f(0,0,0);
						glVertex3f(1,1,1);
						glVertex3f(-1,1,1);
						
						//right
						glNormal3f(1, -1, 0);
						glVertex3f(0,0,0);
						glVertex3f(1,1,-1);
						glVertex3f(1,1,1);
						
						//left
						glNormal3f(-1, -1, 0);
						glVertex3f(0,0,0);
						glVertex3f(-1,1,1);
						glVertex3f(-1,1,-1);
						
						//back
						glNormal3f(0, -1, -1);
						glVertex3f(0,0,0);
						glVertex3f(-1,1,-1);
						glVertex3f(1,1,-1);
						
						//top
						glNormal3f(0, 1, 0);
						glVertex3f(1,1,1);
						glVertex3f(1,1,-1);
						glVertex3f(-1,1,-1);
						
						glNormal3f(0, 1, 0);
						glVertex3f(1,1,1);
						glVertex3f(-1,1,-1);
						glVertex3f(-1,1,1);
						
					glEnd();
					
					glPopMatrix();
				} else
				{
					glColor(Color4b::Green);
					
					glBegin(GL_LINES);
						glVertex(point);
						glVertex(point+(normal*scaleFactor));
					glEnd();
				}
			}
			
			glColor(Color4b::Red);
			glArea->renderText(point[0], point[1], point[2], QString(item->getName()) );	
		}
	}
	
	glDisable(GL_BLEND);
	glDisable(GL_COLOR_MATERIAL);
	glDisable(GL_DEPTH_TEST);
	
	glPopAttrib();
}


Q_EXPORT_PLUGIN(EditPickPointsPlugin)
