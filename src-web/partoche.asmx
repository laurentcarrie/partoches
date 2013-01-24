<%@ Assembly name="System.Json" %>
<%@ Assembly name="System.Core" %>

<%@ WebService Language="C#" Class="partoche.partoche" %>

using System ;
using System.Web.Services ;
using System.Diagnostics ;

using System;
using System.Data;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.ComponentModel;
using System.IO; 

using System.Json ;

namespace partoche {
[WebService (Namespace = "http://tempuri.org/partoche")]

		

public class RootObject
{
    public List<string> files { get; set; }
}

public class MyFileInfo
{
     public string filename { get;set; } 
     public string path  { get;set;}
}
     
								   

public class partoche : WebService
{
  [WebMethod]
  public int Add(int a,int b) {
    return a+b ;
  }   

  [WebMethod]
  public List<MyFileInfo> ls() {
    /*
    string fileName = "mood_for_a_day.json" ;
    FileStream fs = new FileStream(System.Web.Hosting.HostingEnvironment.MapPath
				   ("~/") + "../test/" + fileName, FileMode.Open); 
    var je = System.Json.JsonValue.Load (fs) ;
    fs.Close () ;

    string fileName2 = "save.json" ;
    FileStream fs2 = new FileStream(System.Web.Hosting.HostingEnvironment.MapPath
				   ("~/") + "../test/" + fileName2, FileMode.Create); 
    je.Save(fs2) ;
    fs2.Close() ;
    */
    List<MyFileInfo> ll = new List<MyFileInfo> () ;

    Random random = new Random();
    int randomNumber = random.Next(0,100) ;
    try {
      ProcessStartInfo startInfo = new ProcessStartInfo();
      startInfo.CreateNoWindow = false;
      startInfo.UseShellExecute = false;
      startInfo.FileName = "partoche" ;
      startInfo.WindowStyle = ProcessWindowStyle.Hidden;
      startInfo.Arguments = string.Format ("--list-json --json-id {0}",randomNumber) ;
      startInfo.RedirectStandardOutput = false ;
      startInfo.RedirectStandardError = true;
      // Start the process with the info we specified.
      // Call WaitForExit and then the using statement will close.
      using (Process exeProcess = Process.Start(startInfo))
	{
	  using (StreamReader reader = exeProcess.StandardError)
	    {
	      string result = reader.ReadToEnd();
	      // ll.Add(result) ;
	    }
	  exeProcess.WaitForExit();
	}
    }
    
    catch (Exception ex)
      {
        // return the error message if the operation fails
	// ll.Add(ex.Message.ToString()) ;
      }


    FileStream fs = new FileStream(System.Web.Hosting.HostingEnvironment.MapPath(string.Format("return-{0}.ret",randomNumber)), FileMode.Open); 
    System.Json.JsonValue je = System.Json.JsonValue.Load (fs) ;
    System.Json.JsonObject o = (System.Json.JsonObject) je ;
    System.Json.JsonArray a = (System.Json.JsonArray) (o["files"]) ;
    foreach ( System.Json.JsonValue v2 in a ) {
      System.Json.JsonObject o2 = (System.Json.JsonObject) v2 ;
      MyFileInfo fi = new MyFileInfo () ;
      fi.filename = (string)(o2["filename"]) ;
      fi.path = (string)(o2["path"]) ;
      ll.Add(fi) ;
    }
    fs.Close () ;

    return ll ;
  }

[WebMethod]
public List<MyFileInfo> generate(string fileName) {
  List<MyFileInfo> ll = new List<MyFileInfo>(); 
  try {
    Console.WriteLine("generate all for {0}",fileName) ;
    Random random = new Random();
    int randomNumber = random.Next(0,100) ;
      ProcessStartInfo startInfo = new ProcessStartInfo();
      startInfo.CreateNoWindow = false;
      startInfo.UseShellExecute = false;
      startInfo.FileName = "partoche" ;
      startInfo.WindowStyle = ProcessWindowStyle.Hidden;
      startInfo.Arguments = string.Format ("--verbose --all --json-id {0} {1}",randomNumber,fileName) ;
      startInfo.RedirectStandardOutput = false ;
      startInfo.RedirectStandardError = true;
      // Start the process with the info we specified.
      // Call WaitForExit and then the using statement will close.
      using (Process exeProcess = Process.Start(startInfo))
	{
	  using (StreamReader reader = exeProcess.StandardError)
	    {
	      string result = reader.ReadToEnd();
	      // ll.Add(result) ;
	    }
	  exeProcess.WaitForExit();
	}

      FileStream fs = new FileStream(System.Web.Hosting.HostingEnvironment.MapPath(string.Format("return-{0}.ret",randomNumber)), FileMode.Open); 
      System.Json.JsonValue je = System.Json.JsonValue.Load (fs) ;
      fs.Close () ;
      
      System.Json.JsonObject o = (System.Json.JsonObject) je ;
      System.Json.JsonArray a = (System.Json.JsonArray) (o["files"]) ;
      foreach ( System.Json.JsonValue v2 in a ) {
	System.Json.JsonObject o2 = (System.Json.JsonObject) v2 ;
	MyFileInfo fi = new MyFileInfo () ;
	fi.filename = (string)(o2["filename"]) ;
	fi.path = (string)(o2["path"]) ;
	ll.Add(fi) ;
      }
    }
    
    catch (Exception ex)
      {
        // return the error message if the operation fails
	// ll.Add(ex.Message.ToString()) ;
	Console.WriteLine(ex.Message.ToString()) ;
      }
  return ll ;
}

[WebMethod]
public string UploadFile(byte[] f, string fileName)
{
    // the byte array argument contains the content of the file
    // the string argument contains the name and extension
    // of the file passed in the byte array
    try
    {
        // instance a memory stream and pass the
        // byte array to its constructor
        MemoryStream ms = new MemoryStream(f);
 
        // instance a filestream pointing to the
        // storage folder, use the original file name
        // to name the resulting file
        FileStream fs = new FileStream(System.Web.Hosting.HostingEnvironment.MapPath
                    ("~/TransientStorage/") +fileName, FileMode.Create); 

        // write the memory stream containing the original
        // file as a byte array to the filestream
        ms.WriteTo(fs); 

        // clean up
        ms.Close();
        fs.Close();
        fs.Dispose(); 

        // return OK if we made it this far
        return "OK";
    }
    catch (Exception ex)
    {
        // return the error message if the operation fails
        return ex.Message.ToString();
    }



}


}
}

  
