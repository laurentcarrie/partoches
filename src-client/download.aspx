<%@ Page Language="C#" EnableEventValidation="false" %>

using System.IO;
using System.Threading;

<script runat="server">


protected void Page_Load(object sender, EventArgs e)
{
  string filename = Request["file"].ToString();
  fileDownload(filename, Server.MapPath(filename));
}
private void fileDownload(string fileName, string fileUrl)
{
  Page.Response.Clear();
  bool success = ResponseFile(Page.Request, Page.Response, fileName, fileUrl, 1024000);
  if (!success)
    Response.Write("Downloading Error!");
  Page.Response.End();

}
public static bool ResponseFile(HttpRequest _Request, HttpResponse _Response, string _fileName, string _fullPath, long _speed)
{
  try
    {
      System.IO.FileStream myFile = new System.IO.FileStream(_fullPath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.ReadWrite);
      System.IO.BinaryReader br = new System.IO.BinaryReader(myFile);
      try
	{
	  _Response.AddHeader("Accept-Ranges", "bytes");
	  _Response.Buffer = false;
	  long fileLength = myFile.Length;
	  long startBytes = 0;

	  int pack = 10240; //10K bytes
	  int sleep = (int)Math.Floor((double)(1000 * pack / _speed)) + 1;
	  if (_Request.Headers["Range"] != null)
	    {
	      _Response.StatusCode = 206;
	      string[] range = _Request.Headers["Range"].Split(new char[] { '=', '-' });
	      startBytes = Convert.ToInt64(range[1]);
	    }
	  _Response.AddHeader("Content-Length", (fileLength - startBytes).ToString());
	  if (startBytes != 0)
	    {
	      _Response.AddHeader("Content-Range", string.Format(" bytes {0}-{1}/{2}", startBytes, fileLength - 1, fileLength));
	    }
	  _Response.AddHeader("Connection", "Keep-Alive");
	  _Response.ContentType = "application/octet-stream";
	  _Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(_fileName, System.Text.Encoding.UTF8));

	  br.BaseStream.Seek(startBytes, System.IO.SeekOrigin.Begin);
	  int maxCount = (int)Math.Floor((double)((fileLength - startBytes) / pack)) + 1;

	  for (int i = 0; i < maxCount; i++)
	    {
	      if (_Response.IsClientConnected)
		{
		  _Response.BinaryWrite(br.ReadBytes(pack));
		  System.Threading.Thread.Sleep(sleep);
		}
	      else
		{
		  i = maxCount;
		}
	    }
	}
      catch
	{
	  return false;
	}
      finally
	{
	  br.Close();
	  myFile.Close();
	}
    }
  catch
    {
      return false;
    }
  return true;
}


</script>