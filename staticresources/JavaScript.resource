jQuery(document).ready(function() {
  checkPermission();
  mainPageHandler();
  schedulePageHandler();
  materialPageHandler();

  $(".outerTable").css("display", "none");
  $("[id$='schedulePage']").css("display","none");
  $("[id$='materialsPage']").css("display","none");

});

function sendFileToServer(formData,status, filename, fileres){
  var sfdcHostName = window.location.host.split('.')[1];
  var materialName = $("#materialName").val();
  var materialTheme = $("[id$='materialTheme'] option:selected").text();

  $("#AddMaterialButton").on('click', function() {
    jqXHR.abort();
    $( ".filename" ).remove();
    $( ".filesize" ).remove();
    $( ".progressBar" ).remove();
    $( ".completed" ).remove();
    $(".stubText").removeClass("hidden");
  });

  var uploadURL = 'https://' + sfdcHostName + '.salesforce.com/services/apexrest/DragAndDrop/v1?FileName=' + filename + '&FileResolution=' + fileres + '&MaterialName=' + materialName + '&MaterialTheme=' + materialTheme;
  var jqXHR=$.ajax({
    xhr: function() {
      var xhrobj = $.ajaxSettings.xhr();
      if (xhrobj.upload) {
        xhrobj.upload.addEventListener('progress', function(event) {
          var percent = 0;
          var position = event.loaded || event.position;
          var total = event.total;
          if (event.lengthComputable) {
            percent = Math.ceil(position / total * 100);
          }
            //Set progress
          status.setProgress(percent);
        }, false);
      }
      return xhrobj;
    },
    url: '/services/proxy',
    beforeSend: function(xhr) {
      xhr.setRequestHeader('SalesforceProxy-Endpoint', uploadURL);
      var sfdcSessionId = $('#sessionId').html();
      xhr.setRequestHeader('Authorization', ' Bearer ' + sfdcSessionId);
      xhr.setRequestHeader('X-User-Agent', 'MyClient');
    },
    type: "POST",
    contentType: null,
    crossDomain: true,

    processData: false,
    cache: false,
    data: formData,
    success: function(data, textStatus){
      status.setProgress(100);     
    },       
  }); 
}

function createStatusbar(obj)  {
   this.filename = $("<div class='filename'></div>").appendTo($('#dragandrophandler'));
   this.size = $("<div class='filesize'></div>").appendTo($('#dragandrophandler'));
   this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo($('#dragandrophandler'));
   this.completed = $("<div class='completed'>COMPLETED</div>").appendTo($('#dragandrophandler'));
   $(".stubText").addClass("hidden");
   obj.after(this.statusbar);

   this.setFileNameSize = function(name,size)
   {
    var sizeStr="";
    var sizeKB = size/1024;
    if(parseInt(sizeKB) > 1024) {
      var sizeMB = sizeKB/1024;
      sizeStr = sizeMB.toFixed(2)+" MB";
    } else {
      sizeStr = sizeKB.toFixed(2)+" KB";
    }

    this.filename.html(name);
    this.size.html(sizeStr);
  }

  this.setProgress = function(progress){       
    var progressBarWidth =progress*this.progressBar.width()/ 100;  
    this.progressBar.find('div').animate({ width: progressBarWidth }, 10).html(progress + "% ");
    if(parseInt(progress) >= 100)
    {
     this.progressBar.css( "display", "none" );
     this.size.css("display", "none");
     this.completed.css("display", "inline-block")
   }
 }
}

function handleFileUpload(files,obj){
  filesToUpload = files;
  statuses = [];
  for (var i = 0; i < filesToUpload.length; i++) {
    var status = new createStatusbar(obj); //Using this we can set progress.
    status.setFileNameSize(filesToUpload[i].name,filesToUpload[i].size);
    statuses[i] = status;
  }  
    $("#saveMaterialButton").on("click", function () {
      for (var j = 0; j < filesToUpload.length; j++) {
        sendFileToServer(filesToUpload[j],statuses[j],encodeURI(filesToUpload[j].name.split('.')[0]), filesToUpload[j].name.split('.').pop());
      }
    })
}

function addMaterialHandler() {
  $("[id$='addMaterialBlock']").css("display","none");
  
  $("#AddMaterialButton").on("click", function() {
    if (this.innerHTML == 'ADD MATERIAL') {
      $("[id$='addMaterialBlock']").css("display","block");
      $(this).html('CANCEL');  
    } else {
      $("[id$='addMaterialBlock']").css("display","none");
      $(this).html('ADD MATERIAL'); 
    }
  })
}

function addMaterialBlockHandler() {
  $("#inpFile").css("display","none");
  $("#saveMaterialButton").css("display","none");
  $("[id$='dragandrophandler']").css("display","none");
  
  $( "[id$='materialName']"  ).on( "keyup", function() {
    if ($("[id$='materialName']").val() != '') {
      $("#inpFile").css("display","block");
      $("#saveMaterialButton").css("display","inline-block");
      $("[id$='dragandrophandler']").css("display","block");
    }
    else { 
      $("#inpFile").css("display","none");
      $("#saveMaterialButton").css("display","none");
      $("[id$='dragandrophandler']").css("display","none");
    }
  });
}

function showMaterialsHandler() {
  obj = $("#dragandrophandler");
  $("[id$='selectMaterials']").on( "change", function() {
    $(".outerTable").css("display", "block");
  });

  obj.on('dragenter', function (e) {
    e.stopPropagation();
    e.preventDefault();
    $(this).css('border', '2px dotted #03AD44');
    $(this).css('border-radius', '10px');
  });

  obj.on('dragover', function (e) {
   e.stopPropagation();
   e.preventDefault();
 });

  obj.on('drop', function (e) {
    var files = e.originalEvent.dataTransfer.files;
    uploadFiles(files);
 });

  $("#inpFile").on("change", function(e) {
    var files = e.target.files;
    uploadFiles(files);
  });

  $(document).on('dragenter', function (e) {
    e.stopPropagation();
    e.preventDefault();
  });

  $(document).on('dragover', function (e) {
    e.stopPropagation();
    e.preventDefault();
    obj.css('border', '2px dotted #0B85A1');
    obj.css('border-radius', '0px');
  });

  $(document).on('drop', function (e) {
    e.stopPropagation();
    e.preventDefault();
  });
}

function addScheduleButtonHandler() {
  $( "#addScheduleButton" ).on( "click", function() {
    if (this.value == 'Add Schedule') {
      $("#addScheduleBlock").css('display', 'block');
      $( "#addScheduleButton" ).val('CANCEL');
    } else {
      $("#addScheduleBlock").css('display', 'none');
      $( "#addScheduleButton" ).val('Add Schedule');
    }
  });
}

function checkEnableButton() {
  $( "[id$='sheduleImg']"  ).on( "change", function() {
    if ($("[id$='sheduleImg']")[0].files.length != 0) {
      $("#saveScheduleButton")[0].removeAttribute("disabled");
    } else {
      $("#saveScheduleButton")[0].setAttribute("disabled", "true");
    }
  });
}

function saveSchedule(){
  $("#saveScheduleButton").on( "click", function() {
    if (confirm('Are you shure?')) {
      callSaveSchedule();
      return false;
    } else {
      event.preventDefault();
      event.stopPropagation();
      return false;
    }
  });
}

function mainPageHandler() {
  $( "#MainButton" ).on( "click", function() {
    $("[id$='mainPage']").css('display', 'block');
    $("[id$='schedulePage']").css('display', 'none');
    $("[id$='materialsPage']").css('display', 'none');
  });
}

function schedulePageHandler() {
  var validFileExtensions = [".jpg", ".jpeg", ".bmp", ".gif", ".png"];   
  validateExtention($("[id$='sheduleImg']"), validFileExtensions);
  addScheduleButtonHandler();
  checkEnableButton();
  saveSchedule();
  $( "#ScheduleButton" ).on( "click", function() {
    $("[id$='mainPage']").css('display', 'none');
    $("[id$='schedulePage']").css('display', 'block');
    $("[id$='materialsPage']").css('display', 'none');
  });
}

function materialPageHandler() {
  addMaterialHandler();
  addMaterialBlockHandler();
  showMaterialsHandler();
  $( "#MaterialsButton" ).on( "click", function() {
    $("[id$='mainPage']").css('display', 'none');
    $("[id$='schedulePage']").css('display', 'none');
    $("[id$='materialsPage']").css('display', 'block');
  });
}

function checkIfExistMaterials() {
   if ($("[id$='materialsRepeat']")[0] == undefined) {
    $(".outerTable").css("display", "none");
    $("#materialsTable").append("<p id='noRecords'>There are no records of this theme!");
  } else {
    $("#noRecords").remove();
  }
}

function checkPermission() {
  if ($("#permission").text() == 'true') {
    $(".checkPermission").css("display", "none");
  }
}

function uploadFiles(filesToUpload) {
  var validFileExtensions = ["pdf", "docx", "doc", "txt", "rar", "zip", "rtf", "jpg", "jpeg", "png"];
  var validationSucess = true;   
  for (var i = 0; i < filesToUpload.length; i++) {
    if (!validateExtentionOfFile(filesToUpload[i], validFileExtensions)) {
      alert("Sorry, " + filesToUpload[i].name + " have invalid extension!!! Allowed extensions are: " + validFileExtensions.join(", "));
      validationSucess = false;
      $("#inpFile").removeAttr('type');
      $("#inpFile").attr('type','file')
      break;
    }
  } 
  obj.css('border', '2px dotted #0B85A1');
  obj.css('border-radius', '0px');
  
  if (validationSucess) {
    handleFileUpload(filesToUpload,obj);
  }
}

function validateExtention(objectToValid, validExtention) {
  objectToValid.on( "change", function() {
        var oInput = this;
        if (oInput.type == "file") {
            var sFileName = oInput.value;
            if (sFileName.length > 0) {
                var blnValid = false;
                for (var j = 0; j < validExtention.length; j++) {
                    var sCurExtension = validExtention[j];
                    if (sFileName.substr(sFileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
                        blnValid = true;
                        break;
                    }
                }
                
                if (!blnValid) {
                    alert("Sorry, " + sFileName + " have invalid extension!!! Allowed extensions are: " + validExtention.join(", "));
                    this.value = null;
                    return false;
                }
            }
        }
  });
}

function validateExtentionOfFile(file, validExtention) {
  var blnValid = false;
  var fileName = file.name;
  for (var i = 0; i < validExtention.length; i++) {
    var sCurExtension = validExtention[i];
    if (fileName.substr(fileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
      blnValid = true;
      break;
    }
  }

  if (!blnValid) {
    return false;
  }
  return true;
}