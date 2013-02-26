// delegate
import mx.utils.Delegate;
// ui components
import mx.controls.DataGrid
import mx.controls.Button
// file reference
import flash.net.FileReferenceList;
import flash.net.FileReference;

class MultipleUpload
{
	
	private var fileRef:FileReferenceList;
	private var fileRefListener:Object;
	private var list:Array;
	private var uploading:Boolean;
	
	private var files_dg:DataGrid;
	private var browse_btn:Button;
	private var upload_btn:Button;
	
   	// Constructor (files_dg, browse_btn, upload_btn)
	
	public function MultipleUpload(fdg:DataGrid, bb:Button, ub:Button) 
	{
		// references for objects on the stage
		files_dg = fdg;
		browse_btn = bb;
		upload_btn = ub;
		//
		uploading = false;
		
		// file list references & listener
		fileRef = new FileReferenceList();
		fileRefListener = new Object();
		fileRef.addListener(fileRefListener);
		
		// setup
		iniUI();
		inifileRefListener();
		
	}
	
   	// iniUI
	
	private function iniUI()
	{
		// buttons
		browse_btn.onRelease = Delegate.create(this, this.browse);
		upload_btn.onRelease = Delegate.create(this, this.upload);
		// columns for dataGrid
		files_dg.addColumn("name");
		files_dg.addColumn("size");
		files_dg.addColumn("status");
	}
	
	private function browse()
	{  
	  var allTypes:Array = new Array();

		trace("// browse");
		fileRef.browse([{description: "Media Files", extension: "*"}]);
	}
	
	private function upload()
	{
        var userid:String;
		var server:String;
		var action:String;
		var i:Number;
		
		userid = _root.userid
		server = _root.server
		action = _root.action

		trace("// upload");
		// upload first file
		for(i = 0; i < list.length; i++) {
        	var file = list[i];
		    var file_status = files_dg.getItemAt(i).status
         	trace("status: " + file_status);
			if ((file_status == "ready for upload") and (not uploading)) {
          	  trace("name: " + file.name);
         	  trace(file.addListener(this)); 
          	  //file.upload(server+action+userid);
			  file.upload(action+userid);
			  //upload the first file that is not complete....other files are kicked off once the first is complete
			  uploading = true;
			}
    	}
	}
	
   	// inifileRefListener
	
	private function inifileRefListener()
	{
		fileRefListener.onSelect		= Delegate.create(this, this.onSelect);
		fileRefListener.onCancel		= Delegate.create(this, this.onCancel);
		fileRefListener.onOpen			= Delegate.create(this, this.onOpen);
		fileRefListener.onProgress		= Delegate.create(this, this.onProgress);
		fileRefListener.onComplete		= Delegate.create(this, this.onComplete);
		fileRefListener.onHTTPError		= Delegate.create(this, this.onHTTPError);
		fileRefListener.onIOError		= Delegate.create(this, this.onIOError);
		fileRefListener.onSecurityError	= Delegate.create(this, this.onSecurityError);
	}
	
   	// onSelect
	
	private function onSelect(fileRefList:FileReferenceList)
	{
		trace("// onSelect");
		// list of the file references
		list = fileRefList.fileList;
		// data provider list so we can customize things
		var list_dp = new Array();
		// loop over original list, convert bytes to kilobytes
		for(var i:Number = 0; i < list.length; i++) 
		{
			list_dp.push({name:list[i].name, size:Math.round(list[i].size / 1000) + " kb", status:"ready for upload"});
    	}
		// display list of files in dataGrid
		files_dg.dataProvider = list_dp;
		files_dg.spaceColumnsEqually();
	}
	
   	// onCancel
	
	private function onCancel()
	{
		trace("// onCancel");
	}
	
   	// onOpen
	
	private function onOpen(file:FileReference)
	{
		trace("// onOpenName: " + file.name);
	}
	
   	// onProgress
	
	private function onProgress(file:FileReference, bytesLoaded:Number, bytesTotal:Number)
	{
		trace("// onProgress with bytesLoaded: " + bytesLoaded + " bytesTotal: " + bytesTotal);
		for(var i:Number = 0; i < list.length; i++) 
		{
			if (list[i].name == file.name) {
				var percentDone = Math.round((bytesLoaded / bytesTotal) * 100)
				files_dg.editField(i, "status", "uploading: " + percentDone + "%");
				if (percentDone == 100) {
					 files_dg.editField(i, "status", "Post Processing" );
				}
     			_root.onEnterFrame = function() {
					trace ("onEnterFrame called");
				}

			}
    	}
	}
	
   	// onComplete
	
	private function onComplete(file:FileReference)
	{
		trace("// onComplete: " + file.name);
		for(var i:Number = 0; i < list.length; i++) 
		{
			if (list[i].name == file.name) {
				files_dg.editField(i, "status", "complete");
				//kick off next file upload
				uploading = false;
				upload();
				break;
			}
    }
	}
	
   	// onHTTPError
	
	private function onHTTPError(file:FileReference, httpError:Number)
	{
		var errorMsg: String;
		
		trace("// onHTTPError: " + file.name + " httpError: " + httpError);
		//error message according to returned status
		if (httpError == 500) {
			errorMsg = 'Failed. Try again';
		} else if (httpError == 501) {
			errorMsg = 'Unsupported File Type';
		} else if (httpError == 502) {
			errorMsg = 'Out of Disk Space';
		} else if (httpError == 510) {
			errorMsg = 'Fatal Error';
		} else if (httpError == 520) {
			errorMsg = 'Failed to upload';
		} else {
			errorMsg = 'Failed with '+httpError;
		}
		//
		for(var i:Number = 0; i < list.length; i++) 
		{
			if (list[i].name == file.name) {
				files_dg.editField(i, "status", errorMsg);
				//kick off next file upload
				uploading = false;
				upload();
				break;
			}
   	}
	}
	
   	// onIOError
	
	private function onIOError(file:FileReference)
	{
		trace("// onIOError: " + file.name);
	}
	
   	// onSecurityError
	
	private function onSecurityError(file:FileReference, errorString:String)
	{
		trace("onSecurityError: " + file.name + " errorString: " + errorString);
	}


}