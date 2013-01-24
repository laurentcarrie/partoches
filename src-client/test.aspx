<%@ Page Language="C#" EnableEventValidation="false" %>

<script runat="server">
// on the asp:Button onclick call this method


string class_of_node_value(string value) {
  System.Json.JsonObject o = (System.Json.JsonObject)(System.Json.JsonValue.Parse(value)) ;
  return (string)o["class"] ;
}

public class MyNode : TreeNode {
  public string class_of_value () {
    try {
      System.Json.JsonObject o = (System.Json.JsonObject)(System.Json.JsonValue.Parse(this.Value)) ;
      return (string)o["class"] ;
    }
    catch (Exception ex) {
      Console.WriteLine("class_of_value : {0} ; {2} ; {1}",ex.Message.ToString(),this.Text,this.Value) ;
      return "" ;
    }
  }




  protected override void RenderPreText(System.Web.UI.HtmlTextWriter writer) {
    writer.WriteBeginTag("span") ;
    string classe = this.class_of_value() ;
    if (this.Selected) {
      classe = classe + " jsontreeview_edit" ;
    }
    writer.WriteAttribute("class",classe) ;
    writer.Write(HtmlTextWriter.TagRightChar);
  }
  protected override void RenderPostText(System.Web.UI.HtmlTextWriter writer) {
    writer.WriteEndTag("span") ;
  }
}

void populate() {
  Console.WriteLine("populate") ;
   partoche.partoche p = new partoche.partoche();
   GreetList.Items.Clear() ;
   foreach ( partoche.MyFileInfo s in p.ls() ) {
	Console.WriteLine ("test.aspx -----> {0}",s) ;
	ListItem li = new ListItem() ;
	li.Value = string.Format("{0}/{1}",s.path,s.filename) ;
	li.Text  = string.Format("{0} : {1}",s.path,s.filename) ;
	GreetList.Items.Add(li) ;
   }
}


void generate_Click(Object sender,EventArgs e) {
   partoche.partoche p = new partoche.partoche();
   System.Collections.Generic.List<partoche.MyFileInfo> files = p.generate(GreetList.SelectedItem.Value) ;
   foreach ( partoche.MyFileInfo s in files ) {
	Console.WriteLine ("test.aspx -----> {0}",s) ;
	ListItem li = new ListItem(s.filename,"download.aspx?file="+Server.UrlEncode(".tmp/"+s.filename)) ;
	// li.Value = string.Format("{0}/{1}",s.path,s.filename) ;
	generated_files.Items.Add(li) ;
   }
}


void set_node_value_text(MyNode node,string text,string classe) {
  System.Json.JsonObject o = new System.Json.JsonObject() ;
  o.Add("class",classe) ;
  o.Add("text",text) ; 
  // string s = string.Format("<div class=\"{0}\">{1}</div>",classe,text) ;
  // Console.WriteLine("set_node_value_text {1} -> {0}",classe,text) ;
  // node.Text = s ;
  node.Text = text ;
  node.Value = o.ToString() ;
}


string text_of_node_value(string value) {
  System.Json.JsonObject o = (System.Json.JsonObject)(System.Json.JsonValue.Parse(value)) ;
  return (string)o["text"] ;
}

void set_node_value(MyNode node,string classe) {
  string text = text_of_node_value(node.Value) ;
  set_node_value_text(node,text,classe) ;
}

void SelectedNodeChanged(Object sender,EventArgs e) 
{
  MyNode node = (MyNode)(( (TreeNodeEventArgs)e).Node) ;
  
  string text = node.Text ;
  editbox.Text = text ;
}

void PopulateJson(MyNode parent,System.Json.JsonValue j) {
  try {
  switch (j.JsonType) {
  case System.Json.JsonType.String : {
    MyNode node = new MyNode () ;
    node.PopulateOnDemand = false;
    node.SelectAction = TreeNodeSelectAction.Select ;
    parent.ChildNodes.Add(node);
    set_node_value_text(node,(string)j,"jsontreeview jsontreeview_string") ;
  }
    break ;
  case System.Json.JsonType.Number : {
    MyNode node = new MyNode () ;
    node.PopulateOnDemand = false;
    node.SelectAction = TreeNodeSelectAction.None;
    parent.ChildNodes.Add(node);
    set_node_value_text(node,(string)j,"jsontreeview jsontreeview_string") ;
  }
    break ;
  case System.Json.JsonType.Boolean :{
    MyNode node = new MyNode () ;
    node.PopulateOnDemand = false;
    node.SelectAction = TreeNodeSelectAction.None;
    parent.ChildNodes.Add(node);
    set_node_value_text(node,(string)j,"jsontreeview jsontreeview_string") ;
  }
    break ;
  case System.Json.JsonType.Array : {
    System.Json.JsonArray o = (System.Json.JsonArray) j ;
    System.Collections.Generic.IEnumerator<System.Json.JsonValue> fenum = o.GetEnumerator() ;
    fenum.Reset() ;
    int count=1 ;
    while (fenum.MoveNext()) {
      System.Json.JsonValue item = fenum.Current ;
      MyNode node = new MyNode () ;
      node.PopulateOnDemand = false;
      node.SelectAction = TreeNodeSelectAction.Expand;
      node.Expanded = false ;
      // node.Text = string.Format("<div class=\"jsontreeview_title\">{0}</div>",count) ;
      // node.Text = string.Format("{0}",count) ;
      set_node_value_text(node,string.Format("{0}",count),"jsontreeview_title") ;
      parent.ChildNodes.Add(node);
      PopulateJson(node,item) ;
      count = count+1 ;
    }
  }
    break ;
  case System.Json.JsonType.Object : {
    System.Json.JsonObject o = (System.Json.JsonObject) j ;
    System.Collections.Generic.IEnumerator<System.Collections.Generic.KeyValuePair<string, System.Json.JsonValue>> fenum = o.GetEnumerator() ;
    fenum.Reset() ;
    while (fenum.MoveNext()) {
      System.Collections.Generic.KeyValuePair<string, System.Json.JsonValue> item = (System.Collections.Generic.KeyValuePair<string, System.Json.JsonValue>)fenum.Current ;
      MyNode node = new MyNode () ;
      node.PopulateOnDemand = false;
      node.SelectAction = TreeNodeSelectAction.Expand;
      node.Expanded = false ;
      // node.Text = string.Format("<div class=\"jsontreeview_title\">{0}</div>",item.Key) ;
      set_node_value_text(node,item.Key,"jsontreeview_title") ;
      // node.Text = item.Key ;
      // node.Value = item.Key ;
      parent.ChildNodes.Add(node);
      PopulateJson(node,item.Value) ;
    }
  }
    break; 
  }
  }
    catch (Exception ex) {
      Console.WriteLine("exception : {0}",ex.Message.ToString()) ;
  }
    
}

static MyNode root = null ;

void PopulateTree() {
  string filename = GreetList.SelectedItem.Value ;
  root.ChildNodes.Clear() ;
  root.Text=filename ;
  Console.WriteLine("Populate tree, filename={0}",filename) ;
  System.IO.FileStream fs = new System.IO.FileStream(System.Web.Hosting.HostingEnvironment.MapPath(filename),System.IO.FileMode.Open) ;
  System.Json.JsonValue j = System.Json.JsonValue.Load (fs) ;
  fs.Close() ;
  PopulateJson(root,j) ;	
}

void PopulateNode_cb(Object sender, TreeNodeEventArgs e)
  {
    try {
      TreeNode node =  e.Node ;
      root = new MyNode() ;
      node.ChildNodes.Add(root) ;
      PopulateTree() ;
    }
    catch (Exception ex) {
      Console.WriteLine("exception : {0}",ex.Message.ToString()) ;
    }
 }


void change_value(Object sender,EventArgs e) {
}

void choix_morceau_changed(Object sender,EventArgs e) {
  Console.WriteLine("choix changed") ;
  PopulateTree() ;
}

void Page_Load(object sender,EventArgs e) {
  if (!IsPostBack) {
    populate() ;
  }
  /*
  try {
    string value = Request["value"].ToString();
    Console.WriteLine("page load with {0}",value) ;
    GreetList.SelectedValue=value ;
  }
    catch (Exception ex) {
      Console.WriteLine("exception : {0}",ex.Message.ToString()) ;
  }
  */
}

</script>


<html>
<head>
<title>nos partoches</title>
  <link rel="stylesheet" type="text/css" href="partoches.css" />
</head>
<body>

<form id="choix_morceau" runat="server">
  <h3>Choix du morceau :</h3>
    <asp:DropDownList runat="server" id="GreetList" 
  OnSelectedIndexChanged="choix_morceau_changed"
  autopostback="true"
  >
  </asp:DropDownList>
</form>


<form id="generate" runat="server">
<asp:Button id="generate_btn" onclick="generate_Click" runat="server" Text="generate"></asp:Button>
</form>


<form id="edit" runat="server">
<h3>Boite d'edition</h3>
<asp:TextBox id="editbox" 
TextMode="multiline" 
rows="5"
columns="80"
runat="server" />
<br />

<asp:Button OnClick="change_value" Text="Change" runat="server" />

</form>

<form id="form1" runat="server">

  <h3>Donn&eacute;es : </h3>


      <asp:TreeView id="the_tree"
        CssClass="jsontreeview"
        EnableClientScript="true"
        PopulateNodesFromClient="false"  
        OnTreeNodePopulate="PopulateNode_cb"
        OnSelectedNodeChanged="SelectedNodeChanged"
        HasChildViewState="true" 
        IsViewStateEnabled="true"
        ShowLines="true" 
        runat="server">


        <Nodes>
          <asp:TreeNode Text="xxxx" 
            SelectAction="Expand"  
            PopulateOnDemand="true"/>

        </Nodes>

      </asp:TreeView>

      <br/><br/>

      <asp:Label id="Message" runat="server"/>

    </form>

<div id="the_links">

<asp:BulletedList ID="generated_files" DisplayMode="hyperlink" runat="server">
</asp:BulletedList>

</div>

</body>
</html>
