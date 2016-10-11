* {
	margin: 0px;
}

#softhemeLogo {
    display: inline-block;
    width: 35%;
}

#headText {
    display: inline-block;
    width: 35%;
    font-size: 40px;
    text-align: center;
}

#sfLogo {
    text-align: right;
    display: inline-block;
    width: 28%;
}

#sfLogo img{
    right: 40px;
    position: relative;
}

#header img {
    height: 100px;
}

#logoutBtn {
    top: 0px;
    right: 0px;
    position: absolute;
}

/*-------------------------------------------*/

#navbar button {
	margin: 5px auto;
	font-size: 24px;
}

[id$='mainPage'] h2 {
    margin: 0px;
    text-align: center;
}

[id$='addMaterialBlock'] {
    display: none;
}

[id$='materialName'] {
    border: solid green 1px;
    width: 90%;
    padding-left: 5px;
}

.outerTable {
    width: 100% !important;
} 

.outerTable table {
    width: 100% !important;
}    

.outerTable td, .outerTable th {
    border: none !important;
    padding: 0px !important;
}

.outerTable > tbody > tr{
    border-bottom: solid 1px;
}

.outerTable > tbody > tr > td{
    padding-top: 5px !important;
}

.outerTable > tbody > tr > td:last-child{
    width: 1%;
}

.innerTable td {
    width: 30%;
    border: solid black 1px;
}

.innerTable {
    border-spacing: 5px;
    border-collapse: separate;
}

.inline {
    display: inline-block !important;
    margin-right: 5px;
}

table {
    width: 60% !important;
    border-collapse: collapse;
}

table td {
    border: none !important;
}

[id$="selectMaterials"] {
    margin: 5px auto;
}

#saveScheduleButton:disabled {
    opacity: 0.6;
}

.scheduleImg {
    max-width: 100%;
    margin: 10px auto;
}

.scheduleImg img {
    width: 100%;
}

[id$="scheduleDate"] {
    margin: auto 5px;
}

/*-------------------------------------------*/

#notation {
    height: 500px;
    overflow: auto;
}

.panel-body {
    padding: 5px; 
}

[id$='saveNotationButton'] {
    display: block;
    margin: 5px 0px;
}

[id$='notateionDelete'] {
    background: url("http://www.freeiconspng.com/uploads/remove-icon-png-4.png") 0 0 no-repeat;
    background-size: contain;
    display: inline-block;
    height: 15px;
    text-indent: -9999px;
}

.panel-heading {
    padding: 5px !important;
}

.panel-heading h3 span{
    width: 85% !important;
    display: inline-block;
    font-size: 14px;
}

#addScheduleBlock {
    display: none;
}

#scheduleLeftBlock { 
    min-height: 170px;
}

#saveScheduleButton,#addScheduleButton {
    margin-top: 20px;
}
/*-------------------------------------------*/

footer {
	text-align: center;
}

/*-------------------------------------------*/
@media only screen and (max-width: 1000px) {
    #headText {
        width: 100%;
    }   
    
    #header img {
        display: none;
    }  
    #scheduleLeftBlock {
        min-height: 0px; 
    }  
    #navbar button {
        width: 32%;
    }
    #saveScheduleButton, #addScheduleButton {
        margin-bottom: 20px;
        margin-top: 0px;
    }
}



#dragandrophandler {
    border:2px dotted #0B85A1;
    width:400px;
    color:#92AAB0;

}

#dragandrophandlerSchedule {
    border:2px dotted #0B85A1;
    width:250px;
    color:#92AAB0;

}
.stubText {
    text-align:center;
    vertical-align:middle;
    margin: auto 10px;
    font-size:150%; 
}
.progressBar {
    width: 80%;
    margin-left: 2px;
    height: 22px;
    border: 1px solid #ddd;
    border-radius: 5px; 
    overflow: hidden;
    display:inline-block;
    margin:0px 10px 5px 5px;
    vertical-align:top;
}

.progressBar div {
    height: 100%;
    color: #fff;
    text-align: right;
    line-height: 22px; /* same as #progressBar height if we want text middle aligned */
    width: 0;
    background-color: #0ba1b5; border-radius: 3px; 
}

.filename
{
    margin-left: 6px;
    display: inline-block;
    margin-bottom: 3px;
    margin-right: 5px;
    font-size: 11pt;
    vertical-align:top;
    width:250px;
}
.filesize
{
    display:inline-block;
    vertical-align:top;
    color:#30693D;
    width:100px;
    margin-left:17px;
    margin-right:5px;
}
.completed {
    vertical-align:top;
    color:#03a338;
    font-size: 11pt;
    width:100px;
    margin-left:2px;
    margin-right:5px;
    display: none;
}
.small {
    font-size:125% !important; 
}
.hidden {
    display: none;    
}