jQuery(document).ready(function() {
  checkPermission();
  mainPageHandler();
  schedulePageHandler();
  materialPageHandler();

  $(".outerTable").css("display", "none");
  $("[id$='schedulePage']").css("display","none");
  $("[id$='materialsPage']").css("display","none");
});

function sendFileToServer(objType, formData,status, filename, fileres){
  var sfdcHostName = window.location.host.split('.')[1];

  $("#AddMaterialButton").on('click', function() {
    jqXHR.abort();
    clearDragAndDrop();
  });

  if (objType == 'material') {
    var materialName = encodeURI($("#materialName").val());
    var materialTheme = $("[id$='materialTheme'] option:selected").text();
    var uploadURL = 'https://' + sfdcHostName + '.salesforce.com/services/apexrest/DragAndDrop/materials?FileName=' + filename + '&FileResolution=' + fileres + '&MaterialName=' + materialName + '&MaterialTheme=' + materialTheme;
  } else {
    var scheduleDate = encodeURI($("#sheduleDate").val());
    var uploadURL = 'https://' + sfdcHostName + '.salesforce.com/services/apexrest/DragAndDrop/schedule?FileName=' + filename + '&FileResolution=' + fileres + '&ScheduleDate=' + scheduleDate;
  }
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
      if (objType != 'material') {
        rerenderSchedule();
      }
    },       
  }); 
}

function createStatusbar(objType, obj)  {
  if (objType == 'material') {
    this.filename = $("<div class='filename'></div>").appendTo($('#dragandrophandler'));
    this.size = $("<div class='filesize'></div>").appendTo($('#dragandrophandler'));
    this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo($('#dragandrophandler'));
    this.completed = $("<div class='completed'>COMPLETED</div>").appendTo($('#dragandrophandler'));
  } else {
    this.filename = $("<div class='filename'></div>").appendTo($('#dragandrophandlerSchedule'));
    this.size = $("<div class='filesize'></div>").appendTo($('#dragandrophandlerSchedule'));
    this.progressBar = $("<div class='progressBar'><div></div></div>").appendTo($('#dragandrophandlerSchedule'));
    this.completed = $("<div class='completed'>COMPLETED</div>").appendTo($('#dragandrophandlerSchedule'));
  }
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

function addMaterialButtonHandler() {
  $("[id$='addMaterialBlock']").css("display","none");
  $("#AddMaterialButton").on("click", function() {
    if (this.innerHTML == 'ADD MATERIAL') {
      $("[id$='addMaterialBlock']").css("display","block");
      $(this).html('CANCEL');  
    } else {
      $("[id$='addMaterialBlock']").css("display","none");
      $(this).html('ADD MATERIAL'); 
      $("#saveMaterialButton").css("display","none");
      $("[id$='materialName']")[0].value = '';
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

function addAttachmentHandler(fileType) {
  if (fileType == 'material') {
    obj = $("#dragandrophandler");
    inputFile = $("#inpFile");
    var validFileExtensions = ["pdf", "docx", "doc", "txt", "rar", "zip", "rtf", "jpg", "jpeg", "png"];
    var saveButton = $("#saveMaterialButton");

    $("[id$='selectMaterials']").on( "change", function() {
      $(".outerTable").css("display", "block");
    });    
  }

  if (fileType == 'schedule') {
    obj = $("#dragandrophandlerSchedule");
    inputFile = $("#inpFileSchedule");
    var validFileExtensions = ["jpg", "jpeg", "png"];
    var saveButton = $("#saveScheduleButton");
  }

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
    uploadFiles(fileType, files, validFileExtensions, inputFile, saveButton);
  });

  inputFile.on("change", function(e) {
    var files = e.target.files;
    uploadFiles(fileType, files, validFileExtensions, inputFile, saveButton);
  });
}

function uploadFiles(fileType, filesToUpload, validFileExtensions, inputFile, saveButton) {
  if (fileType == 'schedule') {
    if (filesToUpload.length == '1') {
        $("#saveScheduleButton")[0].removeAttribute("disabled");
      } else {
        alert('You can add only one schedule on one date!');
        return;
      }
  }

  var validationSucess = true;   
  for (var i = 0; i < filesToUpload.length; i++) {
    if (!validateExtentionOfFile(filesToUpload[i], validFileExtensions)) {
      alert("Sorry, " + filesToUpload[i].name + " have invalid extension!!! Allowed extensions are: " + validFileExtensions.join(", "));
      validationSucess = false;
      inputFile.removeAttr('type');
      inputFile.attr('type','file')
      break;
    }
  } 
  obj.css('border', '2px dotted #0B85A1');
  obj.css('border-radius', '0px');
  
  if (validationSucess) {
    handleFileUpload(fileType, saveButton, filesToUpload, obj);
  }
}

function addScheduleButtonHandler() {
  $( "#addScheduleButton" ).on( "click", function() {
    if (this.value == 'Add Schedule') {
      $("#addScheduleBlock").css('display', 'block');
      $("#saveScheduleButton").removeClass("hidden");
      $("#saveScheduleButton")[0].setAttribute("disabled", "true");
      $("#addScheduleButton" ).val('CANCEL');
      dateToday($("#sheduleDate"));
    } else {
      $("#saveScheduleButton").addClass("hidden");
      $("#addScheduleBlock").css('display', 'none');
      $( "#addScheduleButton" ).val('Add Schedule');
    }
  });
}

function mainPageHandler() {
  $( "#MainButton" ).on( "click", function() {
    $("[id$='mainPage']").css('display', 'block');
    $("[id$='schedulePage']").css('display', 'none');
    $("[id$='materialsPage']").css('display', 'none');
  });
  
  $( "#softhemeLogo" ).on( "click", function() {
    location.reload();
  });
}

function schedulePageHandler() {
  documentHandler();
  clearDragAndDrop();
  addScheduleButtonHandler();
  addAttachmentHandler('schedule');
  setScheduleDate();
  $( "#ScheduleButton" ).on( "click", function() {
    $("[id$='mainPage']").css('display', 'none');
    $("[id$='schedulePage']").css('display', 'block');
    $("[id$='materialsPage']").css('display', 'none');
  });
}

function materialPageHandler() {
  clearDragAndDrop();
  addMaterialButtonHandler();
  addMaterialBlockHandler();
  addAttachmentHandler('material');
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

function handleFileUpload(fileType, saveButton, files,obj){
  clearDragAndDrop();
  var filesToUpload = files;
  var statuses = [];
  for (var i = 0; i < filesToUpload.length; i++) {
    var status = new createStatusbar(fileType, obj); //Using this we can set progress.
    status.setFileNameSize(filesToUpload[i].name,filesToUpload[i].size);
    statuses[i] = status;
  }  
    saveButton.on("click", function () {
      for (var j = 0; j < filesToUpload.length; j++) {
        sendFileToServer(fileType, filesToUpload[j],statuses[j],encodeURI(filesToUpload[j].name.split('.')[0]), filesToUpload[j].name.split('.').pop());
      }
    })
}

function documentHandler() {
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

function clearDragAndDrop() {
  $( ".filename" ).remove();
  $( ".filesize" ).remove();
  $( ".progressBar" ).remove();
  $( ".completed" ).remove();
  $(".stubText").removeClass("hidden");
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

function setScheduleDate() {
  $("#sheduleDate").on('change', function() {
    if ($("#sheduleDate")[0].value == '') {
      alert("You can not ass schedule without date!");
      dateToday($("#sheduleDate"));
    }
  });
}

function dateToday(dateField) {
  var today = new Date();
  dateField[0].value = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
}