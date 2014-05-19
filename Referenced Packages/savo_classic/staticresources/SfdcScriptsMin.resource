$(document).ready(function () { 
	// Handling for List widget
	$('div[data-post]').each(function (index, item) {
		var postViewModel = new Savo.Classic.CreatePostViewModel($(item).data('id'), $(item).data('title'));
		postViewModel.GetPost();
		ko.applyBindings(postViewModel, item);
	});

	$('div[data-list]').each(function (index, item) {
		var listViewModel = new Savo.Classic.CreateListViewModel(
		$(item).data('criteria'), $(item).data('tags'), $(item).data('library-ids'),
		$(item).data('asset-types'), $(item).data('num-results'),$(item).data('record-downloads'),
		$(item).data('open-in-tab'),$(item).data('place-holder') );
		
		if($(item).data('default-load') == true)
		{
			listViewModel.AssetModel.GetDocuments();
		}		
		ko.applyBindings(listViewModel, item);
	});
	
	$('div[data-customized-doc]').each(function (index, item) {
		var customizedViewModel = new Savo.Classic.CreateCustomizedViewModel($(item).data('num-results'),
		$(item).data('record-downloads'),$(item).data('open-in-tab'));
		if($(item).data('customized-doc') == true)
		{
			customizedViewModel.AssetModel.GetDocuments();
		}		
		ko.applyBindings(customizedViewModel, item);
	});	
	
	
	$('div[data-multimedia]').each(function (index, item) {
		var videoSupport =  Savo.Classic.CheckVideoSupport();
		var multiMediaViewModel =  new Savo.Classic.CreateMultiMediaViewModel($(item).data('asset-id'),videoSupport);
		if(videoSupport==true)
		{
	   		multiMediaViewModel.GetMultiMediaURL();
	   	}
	   	ko.applyBindings(multiMediaViewModel, item);	   
	});
	
	$('div[data-asset-kit]').each(function (index, item) {
	   var assetkitViewModel =  new Savo.Classic.CreateAssetkitViewModel($(item).data('asset-kit-id')
	   ,$(item).data('num-results'),$(item).data('record-downloads'),$(item).data('open-in-tab'));
	   	if($(item).data('asset-kit') == true)
		{
			assetkitViewModel.AssetModel.GetDocuments();
		}
	   ko.applyBindings(assetkitViewModel, item);	   
	});
});


//************************* Functions are Under Savo.Classic Namespace ***************************//
//***************************************************************************************************//	
(function (ns) {

	//*** Public methods with namespaces.***//

	//show animated loading image    	
	ns.ShowLoading = function (body, image) {
		var element = document.createElement('img');
		element.setAttribute('src', image);
		element.setAttribute('id', 'loadingImage');
		element.setAttribute('alt', 'No Image');
		element.setAttribute('height', '25');
		element.setAttribute('width', '25');
		body.appendChild(element);
	};

	//hide animated loading image
	ns.HideLoading = function () {
		var image = document.getElementById('loadingImage');
		image.parentNode.removeChild(image);
	};

	//function call when error occurs in loading scr to img tag	
	ns.ImageLoadError = function (Id) {
		Id.src = Id.src;
	};

	//Animation GIF image path
	ns.LoadingImagePath = function (imagePath) {
		loadingImagePath = imagePath;
	};

	//path of default user image
	ns.DefaultUserImagePath = function (imagePath) {
		defaultUserImagePath = imagePath;
	};
	
	//SessionId of current user logged in. This will be use in SAVO API
	ns.SessionId = function (psessionId) {
		ns.sessionId = psessionId;
	};

	//Partner URL (e.g. https://ap1....) . This will be use in SAVO API 
	ns.PartnerUrl = function (ppartnerUrl) {
		ns.partnerUrl = ppartnerUrl;
	};
	
	
	ns.Encode = function (value) {
		var result = value;
		if (result != null && result != '') {
			result = result.replace(/,/gi,'%2c');
			result = result.replace(/&/gi,'%26');
		}
		return result;
	};
	
	//Get user Avatar
	ns.GetUserImage = function (userId) {
		return sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiPreviewRepository", "GetUserImageUrl", { userId: userId });
	};

	//Get MetaDataOf Document used for PopUp
	ns.GetDocumentMetaData = function (docId) {	    
		ns.ShowLoading(document.getElementById('loadingPopUp'), loadingImagePath);
		var documentMetaData = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiDocumentRepository", "GetProperties", { documentId: docId });
		var jsonDocument = JSON.parse(documentMetaData);
		ns.HideLoading();
		return jsonDocument;
	};
	
    ns.GetMultimediaDocumentPreviewImage = function(MultimediaUrls)
    {
       return MultimediaUrls[6].Url;
    }

	//Local function to get ImagePath for the document Preview
	ns.GetDocumentPreviewImage = function (docId, preview) {
		if (preview.length > 0) {
			var previewId = preview[0].Id;
			var imageUrl = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiPreviewRepository", "GetImageUrl", { documentId: docId, documentPreviewId: previewId, previewType: 'thumbnail' });
			return imageUrl;
		}
		else
			return "";
	};
	
	//Function call when click on next link in PopUp 
	ns.PopUpPaginationNext = function (docId) {
		var currentPreview = document.getElementById("currentpreview");
		var previewNumber = parseInt(currentPreview.innerHTML);
		var previewLength = document.getElementById("previewLength");
		var previewCount = parseInt(previewLength.innerHTML);
	
		if (previewNumber < previewCount) {
			var documentMetaData = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiDocumentRepository", "GetProperties", { documentId: docId });
			var jsonDocument = JSON.parse(documentMetaData);
			var preview = jsonDocument.Previews;
			var imageUrl = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiPreviewRepository", "GetImageUrl", { documentId: docId, documentPreviewId: preview[previewNumber].Id, previewType: 'thumbnail' });
			currentPreview.innerHTML = previewNumber + 1;
			var imageElement = document.getElementById("thumbnailPreview");
			imageElement.src = imageUrl;
			$('a#popupPrevBtn').css('cursor', 'pointer').css('color', '#333333');
		}
	
		if (previewNumber + 1 < previewCount) {
			$('a#popupNextBtn').css('cursor', 'pointer').css('color', '#333333');
		}
		else {
			$('a#popupNextBtn').css('cursor', 'default').css('color', '#999');
		}
	};
		
	//Function call when click on previous link in PopUp  
	ns.PopUpPaginationPrevious = function (docId) {
		var currentPreview = document.getElementById("currentpreview");
		var previewNumber = parseInt(currentPreview.innerHTML);
		if (previewNumber > 1) {
			var documentMetaData = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiDocumentRepository", "GetProperties", { documentId: docId });
			var jsonDocument = JSON.parse(documentMetaData);
			var preview = jsonDocument.Previews;
			var imageUrl = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiPreviewRepository", "GetImageUrl", { documentId: docId, documentPreviewId: preview[previewNumber - 2].Id, previewType: 'thumbnail' });
			var imageElement = document.getElementById("thumbnailPreview");
			imageElement.src = imageUrl;
			currentPreview.innerHTML = previewNumber - 1;
			$('a#popupNextBtn').css('cursor', 'pointer').css('color', '#333333');
		}
	
		if (previewNumber - 1 > 1) {
			$('a#popupPrevBtn').css('cursor', 'pointer').css('color', '#333333');
		}
		else {
			$('a#popupPrevBtn').css('cursor', 'default').css('color', '#999');
		}
	};
		
	//To download Document
	ns.Download = function (id,isRecordDownload) {
		var url = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiDocumentRepository", "Download", { documentId: id });
		var iframe;
		var hiddenIFrameID = 'hiddenDownloader';
		iframe = document.getElementById(hiddenIFrameID);
		if (iframe === null) {
			iframe = document.createElement('iframe');
			iframe.id = hiddenIFrameID;
			iframe.style.display = 'none';
			document.body.appendChild(iframe);
		}
		iframe.src = url;
		
		if(isRecordDownload == true)
		{
			var docMetaData = Savo.Classic.GetDocumentMetaData(id);
			ns.LogActivityHistory(docMetaData.Title +" was downloaded (Asset ID: "+id+")" ,AccountId);
		}		           
	};
	
	ns.DownloadCustomizeDocument=function(url)
	{
		window.open(url,"_self");
	}
	//Method to store Activity History 
	ns.LogActivityHistory = function(subject,objectId){
	    var record = new sforce.SObject("Task");
		record.Subject = subject;
		record.OwnerId = SFDCUserId;
		record.Status = "Completed";
		record.ActivityDate = new Date();
		record.WhatId = objectId;
		record.WhoId = '';
		var result = sforce.connection.create([record]);
		
		if(result[0].success == 'false' 
			&& result[0].errors.statusCode == 'FIELD_INTEGRITY_EXCEPTION'){
			record.WhoId = objectId;
			record.WhatId = '';
			var result = sforce.connection.create([record]);
		}		 
	};

	//Method to Save Current User ID
	ns.SetSFDCUserId = function (userID) {
		SFDCUserId = userID;
	};
	
	//Method to Save AccountId
	ns.SetAccountId = function (AccId){
	    AccountId = AccId;
	};
	   
	//To get preview URL
	ns.GetUrl = function (UrlToView,openInTab) {
		if(openInTab == true)
		{
			this.redirectToSavoTab("&returnurl=" +UrlToView);
		}
		else
			window.open(this.BuildLink("returnurl=" + this.Encode(UrlToView)));
	};
	
	ns.redirectToUrl = function (relativeUrl,openInTab) {
	    relativeUrl = this.GetSavoUrl() + relativeUrl;
		if(openInTab == true)
		{
			this.redirectToSavoTab("&returnurl=" +relativeUrl);
		}
		else
			window.open(this.BuildLink("returnurl=" + this.Encode(relativeUrl)));
	};
	
	 ns.redirectToTarget = function (target, parameter,openInTab) {
     	var queryString ='';
     	if(target.toLowerCase() == 'platform')
         	queryString = "&returnurl=" + parameter;
     	else
        	queryString =  "&redirectParameter=" + parameter;
     
  		if(openInTab == true)
  		{
  	 		this.redirectToSavoTab("&redirecttarget=" + target + queryString);
  		}
  		else
   			window.open(this.BuildLink("redirecttarget=" + target + queryString));
 	};
		
	ns.redirectToSavoTab=function(relative)
	{
		var savoTabUrl = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiHeaderRepository", "GetSavoTabUrl", {});
   	 	var redirectUrl = savoTabUrl+"&sessionid=" + Savo.Classic.sessionId + "&url=" + Savo.Classic.partnerUrl + relative;
   		window.open(redirectUrl);
	}
	
	//Create Savo Url e.g. www.gosavo.com
	ns.GetSavoUrl = function(){
	   	var apiUrl =sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiHeaderRepository", "GetSavoAPIUrl", {}).toString();
		var baseUrl = apiUrl.substring(apiUrl.indexOf("https"), apiUrl.indexOf("com")) + "com/";
		return baseUrl.replace("api","www");
	};
			
	//Build URL for preview
	ns.BuildLink = function (queryString) {
		var baseUrl = queryString.substring(queryString.indexOf("https"), queryString.indexOf("com")) + "com";
		if(baseUrl=='com')
			baseUrl= this.GetSavoUrl();
		var redirectUrl = baseUrl + "/SingleSignOn/Salesforce.ashx?sessionid=" + Savo.Classic.sessionId + "&url=" + Savo.Classic.partnerUrl;
		// if additional query string information is passed, add it to the redirect url
		if (queryString !== null) {
			redirectUrl = redirectUrl + "&" + queryString;
		}	
		return redirectUrl;
	};		

	//set default Image to user that has no picture
	ns.SetDefaultUser = function (Id) {
		Id.src = defaultUserImagePath;
	};

	//Fetch data from Opportunity and OpportunityLineItems table
		ns.CreateProductDropDown = function(opportunityId, controlId) { 
	  	var result = sforce.connection.query("SELECT Id, Name, (SELECT UnitPrice, PricebookEntry.Name FROM OpportunityLineItems) FROM Opportunity WHERE Id ='" + opportunityId + "'");
	  	var records = result.getArray("records");
	
	  // because we are only dealing with one opportunity, we just want to get the first record
	  if (records != null && records.length > 0)
	  {
		   var opportunity = records[0];
		 
		   // disable the drop down if there are no opportunity line items
		   if (opportunity.OpportunityLineItems === null) { 
		    ns.CreateDropdown(controlId);   
		   } 
		   else {
		    var products = new Array();
		   
		    // check to see if there is only one line item. if so, then get the single item and add it to the products list
		    // otherwise, loop through all the products and add it to the list
		    if (opportunity.OpportunityLineItems.size <= 1) { 
		     products[0] = opportunity.OpportunityLineItems.records.PricebookEntry.Name; 
		    }
		    else {
		     for (var i=0; i < opportunity.OpportunityLineItems.size; i++) { 
		      products[i] = opportunity.OpportunityLineItems.records[i].PricebookEntry.Name;
		     } 
		    }
		    
		    // create the dropdown list containing all opportunity line items
		    ns.CreateDropdown(controlId, products);
		   }
	  } 
	  else
	  	ns.CreateDropdown(controlId);  
	 };
	
	// create and populate a dropdown list
	ns.CreateDropdown = function(id, itemArray) {
		if (itemArray === undefined || itemArray.length === 0) {
			document.write("<select id=\"" + id + "\"  disabled=\"disabled\">");
		}
		else {
			document.write("<select id=\"" + id + "\" > ");
			
			for (var j=0; j < itemArray.length; j++) { 
				document.write("<option value=\"" + itemArray[j] + "\">" + itemArray[j] + "</option>"); 
			}
		}
		document.write("</select>");	
	};
	
	ns.GetInternetExplorerVersion = function()
	{
       var rv = -1; // Return value assumes failure.
       if (navigator.appName == 'Microsoft Internet Explorer')
       {
          var ua = navigator.userAgent;
          var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
          if (re.exec(ua) != null)
             rv = parseFloat( RegExp.$1 );
       }
       return rv;
    }
    
    ns.CheckVideoSupport = function () {
    	var videoSupported = false;
		if(document.createElement('video').canPlayType) {
					videoSupported = true;
		}
		return videoSupported;
    }
      	
	// Method that return package name.
	ns.GetPackageName = function () {		
		return 'savo_classic/';
	};					
//*****************************************************************************************************
	// MultiMedia Functionality
	ns.CreateMultiMediaViewModel = function (id, videoSupport) {
		var multiMediaViewModel = {
		    multiMediaAssetId : ko.observable(id),
			isMediaLoading: ko.observable(true),
			multiMediaSrc : ko.observable(''),
			isVideoSupported : ko.observable(videoSupport)
		};

		// Method to get MultiMedia URL by DocId
			multiMediaViewModel.GetMultiMediaURL = function () {
			this.isMediaLoading(true);
			var assetId = parseInt(this.multiMediaAssetId());
				
			var callback = { onSuccess: this.handleSuccess, onFailure: this.handleFailure, source: this };
			result = sforce.apex.execute(Savo.Classic.GetPackageName() + "ApiDocumentRepository", "GetProperties", { documentId: assetId });
			
			var jsonDocument = JSON.parse(result);				
    		this.multiMediaSrc(jsonDocument.MultimediaUrls[0].Url);
    		this.isMediaLoading(false);
		};
		
  		return multiMediaViewModel;
	};
//*******************************************************************************************//	
	// Post Functionality
	ns.CreatePostViewModel = function (id, title) {
		var postViewModel = {
			widgetHeader: ko.observable(''),
			postId: ko.observable(id),
			postTitle: ko.observable(''),
			postContent: ko.observable(''),
			isPostLoading: ko.observable(true),
			defaultTitle: ko.observable('')
		};

		if(title != null)
		 postViewModel.defaultTitle($.trim(title));

		// Method to get Post by PostId
		postViewModel.GetPost = function () {
			try {
				this.isPostLoading(true);
				//Load the desired SAVO Post
				var postId = parseInt(this.postId());
				var callback = { onSuccess: this.handleSuccess, onFailure: this.handleFailure, source: this };
				sforce.apex.execute(Savo.Classic.GetPackageName() + 'ApiPostRepository', 'Get', { postId: postId }, callback);
			}
			catch (e) {
				this.Title('This Post cannot be displayed at this time.');
			}
		};

		//Callback for Post       
		postViewModel.handleSuccess = function (result, vm) {
			var post = JSON.parse(result);
			if (post.StatusCode != null) {
				throw "Error In API - StatusCode : " + post.StatusCode;
			}
			else {
				vm.postContent(post.Content[0].Value);

				if (vm.defaultTitle().length == 0) {
					vm.postTitle('');
					vm.widgetHeader(post.Title);
				}
				else {
					vm.postTitle(post.Title);
					vm.widgetHeader(vm.defaultTitle());
				}
			}

			vm.isPostLoading(false);
		};

		postViewModel.handleFailure = function (error, vm) {
			vm.widgetHeader(vm.defaultTitle());
			vm.postTitle('This Post cannot be displayed at this time.');
			vm.postContent('');
			vm.isPostLoading(false);
		};

		return postViewModel;
	};
	
	// ************************************************************************************************
	// Generic Document assets view model.
	ns.CreateAssetModel = function (numResults, recordDownloads, openInTab) {
		var assetModel = {
			assets: ko.observableArray(null),
			pageSize: ko.observable(10),
			pageIndex: ko.observable(1), 
			maxPageIndex: ko.observable(0),
			startPageIndex: ko.observable(1),
			lastPageIndex: ko.observable(1),
			totalAssets: ko.observable(0),
			isListLoading: ko.observable(false),
			APIError: ko.observable(''),
			recordDownloads: ko.observable(false),			
			openInTab: ko.observable(false)
		};
	
		assetModel.assets(null);
		
		if(parseInt(numResults) >=1 )
			assetModel.pageSize(parseInt(numResults));
			
		openInTab = openInTab.toString().toLowerCase();
		if( openInTab === true.toString() || openInTab === false.toString())
		   assetModel.openInTab(openInTab);
		
		recordDownloads = recordDownloads.toString().toLowerCase();
		if(recordDownloads === true.toString() || recordDownloads === false.toString())
		  assetModel.recordDownloads(recordDownloads);
			
	    assetModel.ResetClean = function(){
			this.assets(null);
			this.totalAssets(0);
			this.APIError('');
			this.isListLoading(true);
		};	
		
		assetModel.ResetFailure = function(error){
			this.assets(null);
			this.totalAssets(0);
			//	this.APIError(error);
			this.isListLoading(false);
		};	
		
		//Update document widget with next page index                    
		assetModel.NextPage = function () {
			if (this.AssetModel.pageIndex() < this.AssetModel.maxPageIndex()) {
				this.AssetModel.pageIndex(this.AssetModel.pageIndex() + 1);
				this.AssetModel.GetDocuments();
			}
		};

		//Update document widget with first page index
		assetModel.Refresh = function () {
			this.startPageIndex(1);
			this.pageIndex(1);
		};

		//Update document widget with previous page index	
		assetModel.PreviousPage = function () {
			if (this.AssetModel.pageIndex() > 1) {
				this.AssetModel.pageIndex(this.AssetModel.pageIndex() - 1);
				this.AssetModel.GetDocuments();
			}
		};

		//Update document widget with page index on which mouse clicked
		assetModel.MoveToPage = function (index) {
			if (index != this.pageIndex()) {
				this.pageIndex(index);
				this.GetDocuments();
			}
		};
		
		assetModel.viewStatus = ko.computed(function () {
			var status = ''
			if( this.assets() != null && this.totalAssets() > 0)
			{
				status = 'viewing ' + (1+(this.pageIndex() -1) * this.pageSize()) + ' to ' 
				+ Math.min((this.pageIndex() * this.pageSize()), (this.totalAssets())) + ' of ' 
				+ this.totalAssets() + ' assets';
			}
			return status;
		}, assetModel);
		
		assetModel.allPages = ko.dependentObservable(function () {
			var pages = [];
			if(this.totalAssets() > 0)
			{
				var maxPagination = 10;   //No of Pages display in Pagination panel e.g.(<1 2...10>)
	
				if (this.maxPageIndex() < maxPagination && this.maxPageIndex() > 0)
					maxPagination = this.maxPageIndex();
	
				if (this.pageIndex() == (this.lastPageIndex() + 1) && this.pageIndex() <= this.maxPageIndex()) {
					this.startPageIndex(this.pageIndex());
					this.lastPageIndex(this.pageIndex() + (maxPagination - 1));
	
					if (this.lastPageIndex() > this.maxPageIndex())
						this.lastPageIndex(this.maxPageIndex());
				}
				else if (this.pageIndex() == (this.startPageIndex() - 1) && this.pageIndex() != 0) {
					this.startPageIndex(this.startPageIndex() - maxPagination);
					this.lastPageIndex(this.startPageIndex() + (maxPagination - 1));
	
					if (this.lastPageIndex() > this.maxPageIndex())
						this.lastPageIndex(this.maxPageIndex());
				}
	
				if (this.startPageIndex() == 1)
					this.lastPageIndex(maxPagination);
	
				for (i = this.startPageIndex(); i <= this.lastPageIndex(); i++) {
					pages.push({
						pageNumber: (i)
					});
				}
			}
			return pages;
		}, assetModel);
		
		assetModel.HandleFailure = function (error, am) {
			am.ResetFailure(error);
		};
		
		// Asset Model this is object to be used into viewmodel
		assetModel.Asset = function (Id, title, type, owner, createdDate, modifiedDate, averageRating, isDownloadable, isAsset, userUrl, UrlToView, isComment,recordDownloads,isUser,isCustomized,originalFileName,UrlToDownload,UrlToDownloadPDFFile) {
			var self = this;
			self.Id = Id
			self.title = title;
			self.type = type;
		    self.owner = owner;
			self.createdDate = createdDate;
			self.modifiedDate = modifiedDate;
			self.averageRating = averageRating
			self.isDownloadable = isDownloadable;
			self.isAsset = isAsset;
			self.userUrl = userUrl;
			self.UrlToView = UrlToView;
			self.isComment = isComment;
			self.isUser = isUser;	
			self.isCustomized = isCustomized;	
			self.originalFileName=originalFileName;		
			self.UrlToDownload = UrlToDownload;
			self.UrlToDownloadPDFFile=UrlToDownloadPDFFile		
		};
		
		//Get Assets Create collection 
		assetModel.GetAssets = function (assetCollection) {
			var assetsArray = new Array();	    
			for (var i = 0; i < assetCollection.Items.length; i++) {
				if (assetCollection.Items[i].Asset != null) {
					if (assetCollection.Items[i].Asset.Document != null) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].Asset.Document.Id, '' + 
						assetCollection.Items[i].Asset.Document.Title, '' + 
						assetCollection.Items[i].Asset.Document.DocType, '' + 
						assetCollection.Items[i].Asset.Document.Owner.DisplayName, '' + 
						assetCollection.Items[i].Asset.Document.CreatedDate, '' + 
						assetCollection.Items[i].Asset.Document.ModifiedDate, '' + 
						assetCollection.Items[i].Asset.Document.AverageRating, true, true, '', 
						assetCollection.Items[i].Asset.Document.UrlToView, false,true,false,false,'','',''));
					}
					else if (assetCollection.Items[i].Asset.Post != null) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].Asset.Post.Id, '' + 
						assetCollection.Items[i].Asset.Post.Title, 'post', '' + 
						assetCollection.Items[i].Asset.Post.Owner.DisplayName, '' + 
						assetCollection.Items[i].Asset.Post.CreatedDate, '' + 
						assetCollection.Items[i].Asset.Post.ModifiedDate, '' + 
						assetCollection.Items[i].Asset.Post.AverageRating, false, true, '',
						assetCollection.Items[i].Asset.Post.UrlToView, false,true,false,false,'','',''));
					}
					else if (assetCollection.Items[i].Asset.CustomPage != null) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].Asset.CustomPage.Id, '' + 
						assetCollection.Items[i].Asset.CustomPage.Title, 'custompage', '' + 
						assetCollection.Items[i].Asset.CustomPage.Owner.DisplayName, '' + 
						assetCollection.Items[i].Asset.CustomPage.CreatedDate, '' + 
						assetCollection.Items[i].Asset.CustomPage.ModifiedDate, '' + 
						assetCollection.Items[i].Asset.CustomPage.AverageRating, false, true, '', 
						assetCollection.Items[i].Asset.CustomPage.UrlToView, false,true,false,false,'','',''));
					}
					else if (assetCollection.Items[i].Asset.Question != null) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].Asset.Question.Id, '' + 
						assetCollection.Items[i].Asset.Question.Title, 'Question', '' + 
						assetCollection.Items[i].Asset.Question.Owner.DisplayName, '' + 
						assetCollection.Items[i].Asset.Question.CreatedDate, '' + 
						assetCollection.Items[i].Asset.Question.ModifiedDate, '' + 
						assetCollection.Items[i].Asset.Question.AverageRating, false, true, '', 
						assetCollection.Items[i].Asset.Question.UrlToView, false,true,false,false,'','',''));
					}
				}
				else if (assetCollection.Items[i].User != null) {
					assetsArray.push(new this.Asset(assetCollection.Items[i].User.Id, '' + 
					assetCollection.Items[i].User.DisplayName, 'User', '' + 
					assetCollection.Items[i].User.Title, '', '', '', false, false, 
					ns.GetUserImage(assetCollection.Items[i].User.Id), 
					assetCollection.Items[i].User.UrlToView, false ,false,true,false,'','',''));
				}
				else if (assetCollection.Items[i].Comment != null) {
					assetsArray.push(new this.Asset(assetCollection.Items[i].Comment.Id, '' + 
					assetCollection.Items[i].Comment.Body, 'Comment', '' + 
					assetCollection.Items[i].Comment.Creator.Email, '' + 
					assetCollection.Items[i].Comment.CreatedDate, '' + 
					assetCollection.Items[i].Comment.ModifiedDate, '', false, false, '', '', true,false,false,false,'','',''));
				}
				else if (assetCollection.Items[i] != null && assetCollection.Items[i].OriginalFileName != null) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].documentId, '' + 
						assetCollection.Items[i].Title, '' + 
						assetCollection.Items[i].DocType, '' + 
						'', '' + 
						assetCollection.Items[i].CreatedDate, '' + 
						assetCollection.Items[i].CreatedDate, '' + 
						'', false, false, '', 
						Savo.Classic.GetSavoUrl()+'Document/Document.aspx?id='+assetCollection.Items[i].documentId+'&view=',false, false,false,true,''+
						assetCollection.Items[i].OriginalFileName,''+
						Savo.Classic.GetSavoUrl()+'ViewResource.aspx?ResourceId=2&ResourceType=DocumentGeneratedFile&Id='+assetCollection.Items[i].Id,''+
						Savo.Classic.GetSavoUrl()+'ViewResource.aspx?ResourceId=2&ResourceType=PdfGeneratedFile&Id='+assetCollection.Items[i].Id));
				}				
			}
			return assetsArray;
		};
		
		// Callback for successfuly API executed.       
		assetModel.HandleSuccess = function (result, am) {
			var jsonDoc = JSON.parse(result);
			if (jsonDoc.StatusCode != null) {
				throw "Error In API- Status Code : " + jsonDoc.StatusCode;
			}
			else
			{
				am.ResetClean();
				
				var numOfPages = parseInt(jsonDoc.totalResults / jsonDoc.itemsPerPage);
				if ((jsonDoc.totalResults % jsonDoc.itemsPerPage) > 0)
					numOfPages += 1;
	
				var numResults = jsonDoc.itemsPerPage;
				am.maxPageIndex(numOfPages);
				am.totalAssets(jsonDoc.totalResults);
				jDocument = jsonDoc;
				am.assets(am.GetAssets(jDocument));

				am.isListLoading(false);				
			}
		};			
		return assetModel;
	};
	
	// ************************************************************************************************
	// Core Parameters for list/search views.
	ns.CreateListParamsModel = function (criteria, tags, libraryIds, assetTypes, placeHolder) {
		var paramsModel = {
			isLoadFirstTime:ko.observable(true),
			criteria: ko.observable(''),
			tags: ko.observable(''),
			libraryIds: ko.observable(''),
			assetTypes: ko.observable(''),
			placeHolder: ko.observable('Search Savo...')
		};
		
		paramsModel.criteria($.trim(criteria));
		paramsModel.tags(tags);
		paramsModel.libraryIds(libraryIds);
		paramsModel.assetTypes(assetTypes);
		   	
		if(placeHolder != null && ($.trim(placeHolder)).length != 0)
			paramsModel.placeHolder($.trim(placeHolder));
		
		return paramsModel;
	}
	//*****************************************************************************************************
	// List Functionality (Common to Search / List Widget)
	ns.CreateListViewModel = function (criteria, tags, libraryIds, assetTypes, numResults, recordDownloads, openInTab, placeHolder) {
		
		var listViewModel = {
		};

		listViewModel.AssetModel = ns.CreateAssetModel(numResults, recordDownloads, openInTab);
		listViewModel.AssetModel.ParamsModel = ns.CreateListParamsModel(criteria, tags, libraryIds, assetTypes, placeHolder);
		   	
		listViewModel.SearchOnKeyPress = function (data, event){		   	
			this.Refresh();
		};			
		
		listViewModel.AssetModel.GetDocuments = function () {
	    	this.ParamsModel.isLoadFirstTime(false);
			try 
			{
				this.ResetClean();

				var searchQuery = escape(this.ParamsModel.criteria());
				var numberOfResult = this.pageSize();
				var libraryIds = this.ParamsModel.libraryIds();
				var tags = escape(this.ParamsModel.tags());
				var assetTypes = this.ParamsModel.assetTypes();
				var pageNumber = this.pageIndex();
				
				var callback = { onSuccess: this.HandleSuccess, onFailure: this.HandleFailure, source: this };
				var docResult = sforce.apex.execute(Savo.Classic.GetPackageName() + 'ApiSearchRepository', 'Search', 
				{ 
					searchQuery: searchQuery, 
					libraryIds: libraryIds, 
					tags: tags, 
					assetTypes: assetTypes, 
					startPage: pageNumber, 
					numResults: numberOfResult 
				},callback);
			}
			catch (e) {
				document.write(e);
			}
		};
			
		listViewModel.Refresh = function()	{
			this.AssetModel.GetDocuments();
		}	

		return listViewModel;
	};

	// ************************************************************************************************
	// Core Parameters for customized views.
	ns.CreateCustomizedParamsModel = function (numResults, recordDownloads, openInTab) {
		var paramsModel = {
			numResults: ko.observable(10),
			recordDownloads: ko.observable(false),
			openInTab: ko.observable(false)
		};
		paramsModel.numResults(numResults);
		paramsModel.recordDownloads(recordDownloads);
		paramsModel.openInTab(openInTab);
		
		return paramsModel;
	}
	//*****************************************************************************************************
	// List Functionality (Common to Search / List Widget)
	ns.CreateCustomizedViewModel = function (numResults, recordDownloads, openInTab) {
		
		var customizedViewModel = {
		};

		customizedViewModel.AssetModel = ns.CreateAssetModel(numResults, recordDownloads, openInTab);
		customizedViewModel.AssetModel.ParamsModel = ns.CreateCustomizedParamsModel(numResults, recordDownloads, openInTab);
		 
		customizedViewModel.AssetModel.GetDocuments = function () {
			try 
			{
				this.ResetClean();
				var numberOfResult = this.pageSize();
				var pageNumber = this.pageIndex();
				var callback = { onSuccess: this.HandleSuccess, onFailure: this.HandleFailure, source: this };
				var docResult = sforce.apex.execute(Savo.Classic.GetPackageName() + 'ApiDocumentRepository', 
					'GetCustomizedDocuments',{startPage: pageNumber , numResults : numberOfResult},callback);
				
			}
			catch (e) {
				document.write(e);
			}
		};
			
		customizedViewModel.Refresh = function()	{
			this.AssetModel.GetDocuments();
		}	

		return customizedViewModel;
	};
	//*****************************************************************************************************

	// Core Parameters for Assetkit views.
	ns.CreateAssetkitParamsModel = function (kitId, numResults, recordDownloads, openInTab) {
		var paramsModel = {
			kitId: ko.observable(''),
			numResults: ko.observable(10),
			recordDownloads: ko.observable(false),
			openInTab: ko.observable(false)
		};
		paramsModel.kitId(kitId);
		paramsModel.numResults(numResults);
		paramsModel.recordDownloads(recordDownloads);
		paramsModel.openInTab(openInTab);
		
		return paramsModel;
	}
	//*****************************************************************************************************
	ns.CreateAssetkitViewModel = function (kitId,numResults, recordDownloads, openInTab) {
		
		var assetViewModel = {
		};

		assetViewModel.AssetModel = ns.CreateAssetModel(numResults, recordDownloads, openInTab);
		assetViewModel.AssetModel.ParamsModel = ns.CreateAssetkitParamsModel(kitId, numResults, recordDownloads, openInTab);
		 
		assetViewModel.AssetModel.GetDocuments = function () {
			try 
			{
				this.ResetClean();
				var numberOfResult = this.pageSize();
				var pageNumber = this.pageIndex();
				var callback = { onSuccess: this.HandleSuccess, onFailure: this.HandleFailure, source: this };
				var docResult = sforce.apex.execute(Savo.Classic.GetPackageName() + 'ApiDocumentRepository', 
					'GetAssetkitDocuments',{kitId:kitId , startPage:pageNumber, numResults:numberOfResult}, callback);
				
			}
			catch (e) {
				document.write(e);
			}
		};
			
		assetViewModel.Refresh = function()	{
			this.AssetModel.GetDocuments();
		}	
		
			//Get Assets Create collection 
		assetViewModel.AssetModel.GetAssets = function (assetCollection) {
			var assetsArray = new Array();	    
			for (var i = 0; i < assetCollection.Items.length; i++) {
						assetsArray.push(new this.Asset(assetCollection.Items[i].Id, '' + 
						assetCollection.Items[i].Title, '' + 
						assetCollection.Items[i].DocType, '' + 
						assetCollection.Items[i].Owner.DisplayName, '' + 
						assetCollection.Items[i].CreatedDate, '' + 
						assetCollection.Items[i].ModifiedDate, '' + 
						assetCollection.Items[i].AverageRating, true, true, '', 
						assetCollection.Items[i].UrlToView, false,true,false,false,'','',''));
			}
			return assetsArray;
			}

		return assetViewModel;
	};
	//*****************************************************************************************************
	
	
	//private methods
	ns.sessionId;
	ns.partnerUrl;
	// *** Local Variables in namespace *** //
	var defaultUserImagePath;
	var loadingImagePath;
	var SFDCUserId;
	var OpportunityId;
	var AccountId;

})((window.Savo = window.Savo || {}, window.Savo.Classic = window.Savo.Classic || {}));

ko.bindingHandlers.enterKey = {
	init: function(element, valueAccessor, allBindings, vm) {
		ko.utils.registerEventHandler(element, "keyup", function(event) {
			if (event.keyCode === 13) {
				ko.utils.triggerEvent(element, "change");
				valueAccessor().call(vm, vm); //set "this" to the data and also pass it as first arg, in case function has "this" bound
			}
		});
	}         
};
//****************************** JQuery Methods used for pop-up dialog ****************************//
//JQuery method that bind to HTML element once Popup box display when click on Pewview link
//Here need to use ".live" method to bind to element so can't move to namespaces 
//*************************************************************************************************//
	$(function () {
		var xMargin = 10;
		var yMargin = 5;
		var popUpHeight = 195;
		var popUpWidth = 400;

		$("dd[data-popUp]").each(function (index, item) {
			if(index > 0)
				$(item).remove();		
		});
			
		$('a#trigger').live("click", function (e) {
			$("dd[data-popUp]").empty();
			$("div[data-popUpDetails]").remove();
	
			$("dd[data-popUp]").append("<div id='loadingPopUp'></div>");
	
			var popUpLeft = e.pageX;
			var popUpTop = e.pageY;

			var docWidth = $(document).width();
			var docHeight = $(document).height();
	
			var popUpRight = popUpLeft + xMargin + popUpWidth;
			var popUpBottom = popUpTop + yMargin + popUpHeight;
	
			if (popUpRight > docWidth) {
				popUpLeft = popUpLeft - xMargin - (popUpRight - docWidth);
			}
			else {
				popUpLeft = popUpLeft + xMargin;
			}
	
			if (popUpBottom > docHeight) {
				popUpTop = popUpTop - yMargin - (popUpBottom - docHeight);
			}
			else {
				popUpTop = popUpTop + yMargin;
			}
	          
	
			$('dd#pop-up').show()
				.css('top', popUpTop)
				.css('left', popUpLeft)
				.appendTo('body');
	
			var docMetaData = Savo.Classic.GetDocumentMetaData($(this).data('id'));
			var isRecordDownload = $(this).data('record-history');
			var output = "<div data-popUpDetails Id='popUpDetails'>";
			output = output + '<h3>' + docMetaData.Title + '</h3>';
			output = output + '<div class="content">';
			output = output + '<div id="loadThumbnail" class="left">';
			if(docMetaData.Previews.length>0)
            {
                 output = output + '<img id="thumbnailPreview" src="' + Savo.Classic.GetDocumentPreviewImage(docMetaData.Id, docMetaData.Previews) + '" alt="Please wait..." width="140px" height="105px" onerror="Savo.Classic.ImageLoadError(this)">';
                 if(docMetaData.Previews.length>1)
                 {
                     output = output + '<p align="center"><a id="popupPrevBtn" href="javascript:Savo.Classic.PopUpPaginationPrevious(' + docMetaData.Id + ');" style="color: #999;font-weight: bold;cursor: default;text-decoration: none"><span class="arrow-left"></span> Prev  </a>';
                     output = output + '<span id="currentpreview" style="color:#333333;">1</span> <span style="color:#333333;">of</span> <span id="previewLength" style="color:#333333;"> ' + docMetaData.Previews.length + '</span>';
                     output = output + '<a id="popupNextBtn" href="javascript:Savo.Classic.PopUpPaginationNext(' + docMetaData.Id + ');" style="color: #999;font-weight: bold;cursor: default;text-decoration: none">  Next <span class="arrow-right"></span></div></a></p>';
                 }
            }
            
            else if(docMetaData.Previews.length==0 && docMetaData.MultimediaUrls.length==7)
            {
                 output = output + '<img id="thumbnailPreview" src="' + Savo.Classic.GetMultimediaDocumentPreviewImage(docMetaData.MultimediaUrls) + '" alt="Please wait..." width="140px" height="105px" onerror="Savo.Classic.ImageLoadError(this)">';
            }
            else if(docMetaData.Previews.length==0 && docMetaData.MultimediaUrls.length==1)
            {
                 output = output + '<span id="thumbnailPreview" class="icon mmaudio"/>';
            }
			output = output + '</div>';
			output = output + '<div class="right">';
			output = output + '<ul>';
			output = output + '<li>By ' + docMetaData.Owner.DisplayName + '</li>';
			output = output + '<li>Modified: ' + docMetaData.CreatedDate + '</li>';
			output = output + '<li>Created: ' + docMetaData.ModifiedDate + '</li>';
			output = output + '<li>Size: ' + Math.round(docMetaData.FileSize / 1024) + ' KB , ' + docMetaData.Previews.length + ' Slides</li>';
			output = output + '<li>Rating: ' + docMetaData.AverageRating + ' stars</li>';
			output = output + '<li><a id="download" href="javascript:Savo.Classic.Download(' + docMetaData.Id + ','+isRecordDownload+');">Download</a></li>';
			output = output + '</ul>';
			output = output + '</div>';
			output = output + '</div>';
						
			$("dd[data-popUp]").append(output);
			if (docMetaData.Previews.length > 1)
				$('a#popupNextBtn').css('cursor', 'pointer').css('color', '#333333');
	
			$('dd#pop-up').focus();
		});
	
		$(document).mouseup(function (e) {
			var container = $('dd#pop-up');
			if (container.length > 0) {
				if (container.has(e.target).length === 0) {
					container.hide();
				}
			}
		});
	});
	
//*************************************************************************************************//
//*************************************************************************************************//
