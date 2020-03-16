# infoRadiator
Displays work progress for a given sprint

This web site can be placed into the Team City web server root at C:\TeamCity\webapps\ROOT
Example url:  http://192.168.3.211/infoRadiator/display.jsp

In display.jsp the current sprint is assigned to var currentSprintId and the team members are assigned in function updateDisplay() where the build status is requested for each team member.
