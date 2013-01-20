<%@ Page Language="C#" %>
<script runat="server">
// on the asp:Button onclick call this method

void populate() {
   partoche.partoche p = new partoche.partoche();
   GreetList.Items.Clear() ;
   foreach ( partoche.MyFileInfo s in p.ls() ) {
	Console.WriteLine ("test.aspx -----> {0}",s) ;
	ListItem li = new ListItem() ;
	li.Value = string.Format("{0}/{1}",s.path,s.filename) ;
	li.Text  = string.Format("{0} : {1}",s.path,s.filename) ;
	GreetList.Items.Add(li) ;
   }
   GreetList.SelectedIndex=0 ;
}

void onLoad() {
  populate() ;
}

void generate_Click(Object sender,EventArgs e) {
   partoche.partoche p = new partoche.partoche();
   p.generate(GreetList.SelectedItem.Value) ;
}

void populate_Click(Object sender, EventArgs e) {
	populate() ;
}

void runWebService_Click(Object sender, EventArgs e)
{
    partoche.partoche p = new partoche.partoche();
    // call the add method from the webservice
    // pass in the 2 values from the page and convert to integer values
    resultLabel.Text = p.Add(
		  Int32.Parse(number1.Text),
                  Int32.Parse(number2.Text)).ToString();
}


  void PopulateNode(Object sender, TreeNodeEventArgs e)
  {
/*
TreeNode node = e.Node ;
        TreeNode newNode = new TreeNode();
        newNode.Text = "du texte" ;
        newNode.Value = "une valeur" ;

        // Set the PopulateOnDemand property to true so that the child nodes can be 
        // dynamically populated.
        newNode.PopulateOnDemand = true;

        // Set additional properties for the node.
        newNode.SelectAction = TreeNodeSelectAction.Expand;

        // Add the new node to the ChildNodes collection of the parent node.
        node.ChildNodes.Add(newNode);
*/
  }

</script>
<html>
<head>
<title>ASP Web service consumer</title>
</head>
<body onload="onLoad" >
<form runat="server">
      First Number to Add : <asp:TextBox id="number1" runat="server">0</asp:TextBox>
<br/>
      Second Number To Add :
      <asp:TextBox id="number2" runat="server">0</asp:TextBox>
<br/>
      THE WEB SERVICE RESULTS!!!
<br/>
      Adding result : <asp:Label id="resultLabel" runat="server">Result</asp:Label>
<br/>
      <asp:Button id="runService" onclick="runWebService_Click" runat="server" Text="Run the Service"></asp:Button>
      <asp:Button id="populate_btn" onclick="populate_Click" runat="server" Text="populate"></asp:Button>
      <asp:Button id="generate_btn" onclick="generate_Click" runat="server" Text="generate"></asp:Button>



<asp:DropDownList runat="server" id="GreetList" autopostback="true">
</asp:DropDownList>

      <h3>TreeView PopulateNodesFromClient Example</h3>

      <asp:TreeView id="LinksTreeView"
        Font-Names= "Arial"
        ForeColor="Blue"
        EnableClientScript="true"
        PopulateNodesFromClient="true"  
        OnTreeNodePopulate="PopulateNode"
        runat="server">

        <Nodes>

          <asp:TreeNode Text="Inventory" 
            SelectAction="Expand"  
            PopulateOnDemand="true"/>

        </Nodes>

      </asp:TreeView>


</form>


</body>
</html>
