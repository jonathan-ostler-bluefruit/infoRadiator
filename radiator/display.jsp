<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="styles.css">
    <meta charset="UTF-8">
    <title>Team Wolf Radiator</title>
        
    <div> <span style="font-size: 56px;color:#aaa9ad;font-weight:bold"> Team Wolf </span> </div>
    <div> <span id="sprintName" style="font-size: 56px;color:#aaa9ad;"> Sprint </span> </div>
    
    <!--<script src="http://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>-->	
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript" src="js/jquery-1.9.1.js"></script>
    <script type="text/javascript">

    
        jQuery(document).ready(function(){
						
            $("#contented").hide();
            $("#howl").hide();
            $("#running").hide();
            
            var windowWidth = $(window).width();
            var windowWidthHalf = windowWidth / 2;
            var windowWidthThird = windowWidth / 3;
            
            var showContentedWolf = false;
            setInterval(function(){ 
              if (showContentedWolf == true)
              {
                $("#contented").show();
                showContentedWolf = false; 
                updateDisplay();				
              }
              else 
              {
                $("#contented").hide();
                showContentedWolf = true;                
              }
            }, 10000);
						
                 
            // Target process API parameters        
            var targetProcessHostname = 'https://bluefruit.tpondemand.com';
            var targetProcessAuthenticationToken = 'ODM6SnZ1SEhLNS9RMmp6RTVFRlJ5QnVOcnR5dUY2NVg3OXMyYmlJK1Y0d3hsST0=';
            var isTokenSetFromUserProfileTab = true;     
            var takeCount = 100;  

         //   var teamCityHostName = 'http://192.168.3.211/httpAuth/app/rest';
         //   var teamCityHostName = 'http://192.168.3.211/guestAuth/app/rest';
         //   var teamCityHostName = 'http://192.168.3.211/app/rest';
              var teamCityHostName = 'http://192.168.3.211/app/rest/latest';
                             
            var filter = '';
            var includeFields = ''
                
            var currentSprintId = 20477;
            var sprintStartDate;
            var sprintEndDate;
            
            var totalOpenStories = 0;
            var totalPlannedStories = 0;
            var totalInProgressStories = 0;
            var totalForReviewStories = 0;
            var totalInTestingStories = 0;
            var totalDoneStories = 0;
            
            var totalOpenBugs = 0;
            var totalPlannedBugs = 0;
            var totalInProgressBugs = 0;
            var totalForReviewBugs = 0;
            var totalInTestingBugs = 0;
            var totalDoneBugs = 0;
            
            
            var getSprint = jQuery('#SprintButton')     
            showSprint();  
            updateDisplay();
            
            var googleChartsLoaded = false;
            var timeChart;
            google.charts.load('current', {'packages':['corechart']});	
            google.charts.setOnLoadCallback(drawSprintPie);

            function drawSprintPie()             
            {	
              googleChartsLoaded = true;
            
              var today = new Date();
              var timeDiff = today.getTime()-sprintStartDate.getTime();
              var daysPassed = timeDiff / (1000 * 3600 * 24); 
              timeDiff = sprintEndDate.getTime()-today.getTime();          
              var daysLeft = timeDiff / (1000 * 3600 * 24);              
              if (daysLeft < 0)
              {
                daysLeft = 0;
              }
              console.log('days left = '+daysLeft);
                        
              var sprintTimeData = google.visualization.arrayToDataTable([
                ['Task', 'Sprint time'],
                ['passed', daysPassed],
                ['remaining', daysLeft]
              ]);
              
              var options = {
                legend: 'none',
                backgroundColor: 'transparent',
                pieSliceText: 'none',				 
                tooltip: { trigger: 'none' },
                slices: {
                0: { color: 'transparent' },
                1: { color: 'green' }
                }
              };
              
              timeChart = new google.visualization.PieChart(document.getElementById('divSprintTime'));	
              timeChart.draw(sprintTimeData, options);	
              $("#sprintDaysLeft").text(daysLeft + ' Days left');
            }
         
            function showSprint()
            {
              filter = 'Id eq ' + currentSprintId;
              getTargetProcessData('iterations', filter, 1, '', displaySprint);
            }
            
            function displaySprint(data)
            {
              console.log('--- displaySprint -----');
              console.log(data);
              
              var dateStr = data.Items[0].StartDate;
              sprintStartDate = new Date(parseInt(dateStr.substr(6)));  
              
              dateStr = data.Items[0].EndDate;              
              sprintEndDate = new Date(parseInt(dateStr.substr(6)));  
              
              var datestring = sprintEndDate.getDate()  + "-" + (sprintEndDate.getMonth()+1) + "-" + sprintEndDate.getFullYear();   
              $("#sprintName").text(data.Items[0].Name + "     Ends on: "+datestring); 			 
            }
			
            function updateDisplay()
            {
              getOpenStoryCards();
              checkRunningBuild();
              getBuildStatus('Jonathan','WatsonMarlowPepsi_Jonathan');   
              getBuildStatus('Ross','WatsonMarlowPepsi_Ross'); 
              getBuildStatus('Denzil','WatsonMarlowPepsi_Denzil');
              getBuildStatus('Ben','WatsonMarlowPepsi_BenWattsJones'); 

              if (googleChartsLoaded == true)
              {
                drawSprintPie();
              }
            }
			
                        
            function adjustBarWidth(divItem, itemCount, doAppend)
            {
            //  console.log(windowWidthThird + ',' +itemCount);
              var PreviousWidth = $(divItem).width();
             // $(divItem).width((windowWidthThird / 10) * itemCount);
              $(divItem).width((windowWidthHalf / 10) * itemCount);              
              if (doAppend == true)
              {
             //   console.log("current width:" +$(divItem).width()+" PreviousWidth:"+PreviousWidth);
                
                $(divItem).width($(divItem).width() + PreviousWidth)
              }
            }
            
            function adjustDivText(divItem, text)
            {
              $(divItem).css({
                fontSize: 20
              });
              $(divItem).text(text);              
            }
            
            function adjustSpanText(spanItem, text)
            {
              $(spanItem).text(text);
            }
            
            


//------- Stories -------//
            
            var getStories = jQuery('#StoriesButton')
            getStories.bind('click', function () {
              getOpenStoryCards();
            })
            
            function getOpenStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Open")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayOpenStoryCards)
            }
            
            
            function displayOpenStoryCards(data)
            {
              console.log('open Story cards',data);              
              adjustBarWidth("#openCardsBar", data.Items.length, false);              
              totalOpenStories = data.Items.length;            
              getPlannedStoryCards();              
            }
            
            function getPlannedStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Planned")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayPlannedStoryCards)
            }
            
            function displayPlannedStoryCards(data)
            {
            //  console.log('planned Story cards',data);
              adjustBarWidth("#plannedCardsBar", data.Items.length, false);
              totalPlannedStories = data.Items.length;     
              getInProgressStoryCards();              
            }
            
            function getInProgressStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "In Progress")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayInProgressStoryCards)
            }
            
            function displayInProgressStoryCards(data)
            {
            //  console.log('in progress Story cards',data);
              adjustBarWidth("#inProgressCardsBar", data.Items.length, false);
              totalInProgressStories = data.Items.length;     
              getForReviewStoryCards();              
            }
            
            function getForReviewStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "For Review")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayForReviewStoryCards)
            }
            
            function displayForReviewStoryCards(data)
            {
            //  console.log('for review Story cards',data);
              adjustBarWidth("#reviewCardsBar", data.Items.length, false);
              totalForReviewStories = data.Items.length;     
              getInTestingStoryCards();              
            }
            
            function getInTestingStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "In Testing")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayInTestingStoryCards)
            }
            
            function displayInTestingStoryCards(data)
            {
            // console.log('in testing Story cards',data);
              adjustBarWidth("#testingCardsBar", data.Items.length, false);
              totalInTestingStories = data.Items.length;     
              getDoneStoryCards();              
            }
            
            function getDoneStoryCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Done")';
              getTargetProcessData('userstories', filter, 100, '[Id,Iteration,EntityState];', displayDoneStoryCards)
            }
            
            function displayDoneStoryCards(data)
            {
            //  console.log('done Story cards',data);
              adjustBarWidth("#doneCardsBar", data.Items.length, false);
              totalDoneStories = data.Items.length;     
              getOpenBugCards();
            }
            

 //------- Bugs -------//

            function getOpenBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Open")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayOpenBugCards)
            }

            function displayOpenBugCards(data)
            {
            //  console.log('open bug cards',data);              
              adjustBarWidth("#openCardsBar", data.Items.length, true);
              
              totalOpenBugs = data.Items.length;
              adjustSpanText("#openCardsTotals", "OPEN Stories:"+totalOpenStories+",  Bugs:"+totalOpenBugs);
              getPlannedBugCards();              
            }
            
            function getPlannedBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Planned")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayPlannedBugCards)
            }
            
            function displayPlannedBugCards(data)
            {
            //  console.log('planned bug cards',data);              
              adjustBarWidth("#plannedCardsBar", data.Items.length, true);
              
              totalPlannedBugs = data.Items.length;
              adjustSpanText("#plannedCardsTotals", "PLANNED Stories:"+totalPlannedStories+",  Bugs:"+totalPlannedBugs);
              getInProgressBugCards();              
            }
            
            function getInProgressBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "In Progress")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayInProgressBugCards)
            }
            
            function displayInProgressBugCards(data)
            {
            //  console.log('in progress bug cards',data);              
              adjustBarWidth("#inProgressCardsBar", data.Items.length, true);
              
              totalInProgressBugs = data.Items.length;              
              adjustSpanText("#inProgressCardsTotals", "IN PROGRESS Stories:"+totalInProgressStories+",  Bugs:"+totalInProgressBugs);              
              getForReviewBugCards();              
            }
            
            function getForReviewBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "For Review")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayForReviewBugCards)
            }
            
            function displayForReviewBugCards(data)
            {
             // console.log('for review bug cards',data);              
              adjustBarWidth("#reviewCardsBar", data.Items.length, true);
              
              totalForReviewBugs = data.Items.length;
              adjustSpanText("#reviewCardsTotals", "FOR REVIEW Stories:"+totalForReviewStories+",  Bugs:"+totalForReviewBugs);
              getInTestingBugCards();              
            }
            
            function getInTestingBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "In Testing")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayInTestingBugCards)
            }
            
            function displayInTestingBugCards(data)
            {
            //  console.log('in testing bug cards',data);              
              adjustBarWidth("#testingCardsBar", data.Items.length, true);
              
              totalInTestingBugs = data.Items.length;
              adjustSpanText("#testingCardsTotals", "IN TESTING Stories:"+totalInTestingStories+",  Bugs:"+totalInTestingBugs);
              getDoneBugCards();              
            }
            
            function getDoneBugCards()
            {
              filter = '(Iteration.Id eq '+currentSprintId+')and(EntityState.Name eq "Done")';
              getTargetProcessData('bugs', filter, 100, '[Id,Iteration,EntityState];', displayDoneBugCards)
            }
            
            function displayDoneBugCards(data)
            {
            //  console.log('done bug cards',data);              
              adjustBarWidth("#doneCardsBar", data.Items.length, true);
              
              totalDoneBugs = data.Items.length;
              adjustSpanText("#doneCardsTotals", "DONE Stories:"+totalDoneStories+",  Bugs:"+totalDoneBugs);
            }

 
 //------- Target Process API -------// 
                         
            
            function getTargetProcessData(entityTypeResourceName, filter, takeCount, includeFields, callbackFnc)
            {
              var dataUrl = targetProcessHostname + '/api/v1/' + entityTypeResourceName + '?format=json' +        
                  '&where=' + filter +
                  '&take=' + takeCount +
                  (includeFields.length > 0 ? '&include=' + includeFields : '') +
                  '&' + (isTokenSetFromUserProfileTab ? 'access_token' : 'token') + '=' + targetProcessAuthenticationToken;

              $.ajax({
                  type: 'GET',
                  url: dataUrl,
                  dataType: 'jsonp',
                  success: function(data) {
                      console.log('Success', data);
                      callbackFnc(data);
                  },
                  error: function(request, textStatus, errorThrown) {
                      console.log('Error', request.responseText, textStatus, errorThrown);
                  }
              });  
            }
            
            
 //------- Builds (TeamCity) ---------//

            function getTeamCityDate (date)
            {
              var tcDate = date.toISOString();
              var res = tcDate.replace(/-/g, '');
              var res = res.replace(/:/g, '');
              var pos = res.indexOf(".");
              console.log('---- pos = '+pos);
              var res = res.substring(0,pos);
              res = res +  "%2b0000";
              return res;
            }
 
            function checkRunningBuild()
            {
              getTeamCityData('builds', '?locator=running:true,project(id:WatsonMarlowPepsi)', '', displayRunningBuild);     
            }
 
            function getBuildStatus(devName,buildTypeId)
            {
              console.log('getting build status...'); 
              $("#howlListDiv").empty();
     
              // Attempt to get builds since certain times in the past
              var pastDate = new Date();
              pastDate.setDate(pastDate.getDate()-1);
              //  pastDate.setMinutes(pastDate.getMinutes() - 30);
              var pastDateString = getTeamCityDate(pastDate);
              console.log('------ '+pastDateString+'-------' );
              getTeamCityData('buildTypes', '/id:'+buildTypeId+'/builds/?locator=branch:default:any,count:1,sinceDate:'+pastDateString, devName, displayBuildProblems);
              
             // getTeamCityData('builds', '?locator=running:false,status:FAILURE,project(id:WatsonMarlowPepsi),sinceDate:'+dayAgoString, devName, displayBuildProblems);  			  			  
             
            }
			
            function displayRunningBuild(data, devName)
            {				
              var builds = data.getElementsByTagName('builds');
              console.log('***** RUNNING BUILD ****** '+builds[0].children.length);
              if (builds[0].children.length > 0)
              {
                $("#running").show();
              }
              else
              {
                $("#running").hide();
              }
            }
            
            function displayBuildProblems(data, devName)
            {
              $("#howl").hide();              
              var builds = data.getElementsByTagName('builds');
              console.log(builds);					
              if (builds.length > 0)
              {                              
                var buildInfo = builds[0].innerHTML;
                console.log('-----  status '+buildInfo);
                if (buildInfo.includes('status="FAILURE"'))
                {
                  $("#howl").show();                  
                  $('<span style="font-size: 48px;color:red; font-weight:bold">'+devName+'<br/></span>').appendTo('#howlListDiv');
                }
              }
            }
			

 //------- Builds API (TeamCity) -----// 
 
            function getTeamCityData(entityTypeResourceName, filter, devName, callbackFnc)
            {            
              var dataUrl = teamCityHostName + '/' + entityTypeResourceName;                  
              dataUrl = dataUrl + filter;

              $.ajax({
                  type: 'GET',
                  url: dataUrl, 
                  contentType: 'application/xml',				  			   
                  success: function(data) {
                      console.log('getting build status Success', data);
                      callbackFnc(data,devName);                      
                  },
                  error: function(request, textStatus, errorThrown) {
                      console.log('getting build status Error', request.responseText, textStatus, errorThrown);
                  }
              });  
            }
                      
            
              
            var getBuildRunning = jQuery('#RunningButton')
              
            getBuildRunning.bind('click', function () {
              $("#running").show();
            })
            
            var getBuildError = jQuery('#BuildErrorButton')
              
            getBuildError.bind('click', function () {
              $("#howl").show();
            })
            
        });
    </script>
</head>

<style>
body {
  background-image: url('bg1.jpg');
}
</style>

<body>

<!--
<button id="StoriesButton">
    User Stories
</button>
<button id="RunningButton">
    Build Running
</button>
<button id="BuildErrorButton">
    Build Error
</button>
-->

<div id="divSprintTime"></div>

<div id="sprintDays">
  <span id="sprintDaysLeft" style="font-size: 56px;color:#aaa9ad; font-weight:bold"></span>
</div>

<div id="divHowl">
<picture id="howl">
  <img src=https://media.giphy.com/media/rnlt0MRlFhOve/giphy.gif style="width:300px;height:200px;">
</picture>
<div id="howlListDiv"> </div>
</div>

<div id="divRunning">
<picture id="running" >
  <img src=https://tenor.com/view/wolf-grey-running-gif-3530639.gif style="width:300px;height:200px;">
</picture>
</div>


<div style="height:50px; "> </div>
<span id="openCardsTotals" class="rounded-corners" style="font-size: 24px; color:white;background-color:red">Open</span> 
<div id="openCardsBar"  class="rounded-corners"" style="background-color:red;width:10px;height:50px; "></div>

<div style="height:10px; "> </div>

<span id="plannedCardsTotals"  class="rounded-corners" style="font-size: 24px; color:white;background-color:#c27163">Planned</span>
<div id="plannedCardsBar"  class="rounded-corners" style="background-color:#;width:10px;height:50px; "></div>

<div style="height:20px; "> </div>

<span id="inProgressCardsTotals"  class="rounded-corners" style="font-size: 24px; color:white;background-color:green">In Progress</span>
<div id="inProgressCardsBar"  class="rounded-corners" style="background-color:green;width:10px;height:50px; "></div>

<div style="height:20px; "> </div>

<span id="reviewCardsTotals"  class="rounded-corners" style="font-size: 24px; color:white;background-color:#b08d57">For Review</span>
<div id="reviewCardsBar"  class="rounded-corners" style="background-color:#b08d57;width:10px;height:50px; "></div>

<div style="height:10px; "> </div>

<span id="testingCardsTotals"  class="rounded-corners" class="rounded-corners" style="font-size: 24px; color:white;background-color:#aaa9ad">In Testing  </span>
<div id="testingCardsBar"  class="rounded-corners" style="background-color:#aaa9ad;width:10px;height:50px; "></div> 

<div style="height:20px; "> </div>

<span id="doneCardsTotals"  class="rounded-corners" style="font-size: 24px; color:white;background-color:#d4af37">Done</span>
<div id="doneCardsBar"  class="rounded-corners" style="background-color:#d4af37;width:10px;height:50px; "></div>

<div style="height:20px; "> </div>
<div>
<picture id="contented">
  <img src=https://media.giphy.com/media/xjrcshlP992yk/giphy.gif style="width:200px;height:200px;">
</picture>
<div>






</body>
</html>