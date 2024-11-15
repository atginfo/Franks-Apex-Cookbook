# Dynamic Quote Document Templates

## Introduction
Within Salesforce CPQ we have the ability to create SBQQ__QuoteTemplate__c records to facilitate output document generation for any Quote. In some cases, we want to add additional programmatic flare to this document before it gets generated. Whether it's to conditionally display certain fields or control some of the styling of the document, we can accomplish this with an Apex Controller and VisualForce page.

These solutions will cover two use cases where we can apply conditional logic to specific template sections; one for the Quote Lines and one for the Quote Header. 

This README will serve as a supplemental guide to the Trailhead "Quote Templates in Salesforce CPQ" and most specifically the "Insert Visualforce Content and Troubleshoot Templates" section.
Assuming you have at least a SBQQ__QuoteTemplate__c record and a SBQQ__TemplateSection__c child record associated with the template, anyone will be able to plug in these solutions into their Salesforce Orgs.

https://trailhead.salesforce.com/content/learn/modules/quote-templates-in-salesforce-cpq/insert-visualforce-content-and-troubleshoot-templates

### Dynamic Quote Lines
This solution aims to do the following:
- Display all Quote Lines in a table or tables if Quote Line Groups are present
- Conditionally render the Additional Discount Amount and Percentage columns if either are detected on the line items
- Sum up and display the Net Totals of all Quote Lines for the Quote or each Group if present

To accomplish dynamic grouping of Quote Lines we use an inner class within the DynamicQuoteLineController. At it's most basic, we store the Quote Lines associated with a specific group under the lines collection and set up a sum variable (netTotalSum). We then create a public Map<String, GroupedLines> groupToLineItemsMap{get;set;} to associated each GroupedLines to a group with each key being a concatenation of the ```SBQQ__QuoteLineGroup__c.SBQQ__Number__c + SBQQ__QuoteLineGroup__c.Name```. If Quote Line Groups are not being used, we group every line item under the Quote Name instead. This inner class can be expanded on to include more sum variables, collections or booleans to control rendering for individual groups.
```
public class GroupedLines{
        public List<SBQQ__QuoteLine__c> lines {get; set;}
        public Double netTotalSum {get; set;}
       
        public GroupedLines(List<SBQQ__QuoteLine__c> lineItems, Double netSum ) {
            this.lines = lineItems;
            this.netTotalSum = netSum;
        }  
}
```
To control rendering of specific columns, we set up two variables a controlling boolean and a string to hold the table-column - column-width value. ```showDiscount``` will initially be set as false unless it detects that either a line item's ```SBQQ__AdditionalDiscountAmount__c``` or ```SBQQ__Discount__c``` is greater than 0, in which it will be set as true. After all processing is done, the ```setColumnWidths``` method will be called and will set the width string ```addtlDiscWidth``` to either 'auto' or '0%'. 'auto' will help the table column adjust itself according to the size of the values in the column and the overall table width while '0%' will completely shrink the column into its neighbor column similar to hiding columns in Excel.
```
public boolean showDiscount {get;set;}
public string addtlDiscWidth {get;set;}

public void populateQuoteLineData() {
    /** Beginning logic to query quote lines **/

    for (SBQQ__QuoteLine__c ql : quoteLines) {
        // set boolean
        if( (ql.SBQQ__AdditionalDiscountAmount__c > 0 || ql.SBQQ__Discount__c > 0)  && showDiscount != true) {
            showDiscount = true;
        }

         /** Finishing logic to process quote lines **/
    }
}
public void setColumnWidths() {   
    // Ternary to set column-width to 0% if the boolean is false
    addtlDiscWidth = this.showDiscount ? 'auto' : '0%'; 
}
```
In the VisualForce page, we loop through the ```groupToLineItemsMap``` that we populate in the controller using ```<apex:repeat>```. This loops through the keyset of ```groupToLineItemsMap``` which we assign ```g``` as the variable. ```<block>``` tags will be used to display text and apply some styling to anything within the tag, in this case we use ```{!g}``` to indicate the title for the group's table. We create our table columns and header section and then we build our table-body using another ```<apex:repeat>```. Instead the value is going to be using this group's line items ```{!groupToLineItemsMap[g].lines}``` and assigning ```line``` as the variable. From here, we build table-rows with table-cells using field references for the line items, like ```{!line.SBQQ__ProductCode__c }```. Once the loop finishes, we add one more table-row at the end to display the ```{!groupToLineItemsMap[g].netTotalSum}``` for that group before moving on to the next table. 

```
<block font-size="{!template.SBQQ__FontSize__c}" font-family="{!template.SBQQ__FontFamily__c}" >
      <!-- 1st apex:repeat, loop through keySet of each Quote Line Group -->
      <apex:repeat id="grouprepeat" value="{!groupToLineItemsMap}" var="g">
          <!-- Group Title/ Displays Quote Number if No ql groups exist -->
          <block text-align="left" font-size="10px" padding="3px">{!g}</block> 

          <!-- Create a new table for each Quote Line Group - with all borders, bold and shaded top and bottom rows -->
          <table width="100%">
            <!-- table columns -->
            <!-- table header -->
            <table-body>
                <!-- 2nd apex:repeat, looping through the associated line items for each Quote Line Group -->
                <apex:repeat id="linesrepeat" value="{!groupToLineItemsMap[g].lines}" var="line">
                  <table-row keep-together.within-page="always">
                    <table-cell padding="3px" border-style="solid" border-width="1px" text-align="left">
                        <block>{!line.SBQQ__ProductCode__c }</block>
                    </table-cell>
                    <!-- creating table cells for each column-->
                  </table-row>
                </apex:repeat>
                <table-row keep-together.within-page="always" font-weight="bold" background-color="#{!template.SBQQ__ShadingColor__c}">
                    <!-- Label for row -->
                    <table-cell padding="3px" border-style="solid" border-width="1px" text-align="right">
                        <block>{!g} - Subtotal:</block> 
                    </table-cell>
                    <!-- 6 empty table cell tags -->
                    <table-cell padding="3px" border-style="solid" border-width="1px" text-align="right">
                          <block>
                              <apex:outputText value="{0,number,currency}">
                                  <apex:param value="{!groupToLineItemsMap[g].netTotalSum}"/>
                              </apex:outputText>
                          </block> 
                      </table-cell>
                </table-row>
              </table-body>
            </table>
```
Rendering is handled in a unique way with output documents. Since we don't have access to common techniques to conditionally render elements like CSS, we have to be a little more creative. This is where ```showDiscount``` and ```addtlDiscWidth``` come in handy. When setting up our column-widths for each ```<table-column>``` we can set a static value within the VF page or we can tie a dynamic variable to it in the controller. In this case, ```addtlDiscWidth``` is assigned to the column storing Addtl Discount Amount and Addtl Discount Percent. So now if ```showDiscount``` is false, this column will be set to 0%, shrinking to column. If true, it will be set to auto, allowing the table to adjust the rest of its columns with these two columns present.

```
<!-- Create a new table for each Quote Line Group - with all borders, bold and shaded top and bottom rows -->
<table width="100%">

    <!-- Setting columns - Very important when building tables -->
    <!-- Code -->
    <table-column column-width="35%"/> 
    <!-- Name -->
    <table-column column-width="auto"/>
    <!-- Quantity -->
    <table-column column-width="auto"/>
    <!-- List Price -->
    <table-column column-width="auto"/>
    <!-- Addtl Discount Amount - conditional -->
    <table-column column-width="{!addtlDiscWidth}"/>
    <!-- Addtl Discount Percent - conditional -->
    <table-column column-width="{!addtlDiscWidth}"/>
    <!-- Net Price -->
    <table-column column-width="auto"/>
    <!-- Net Total -->
    <table-column column-width="auto"/>
```
Along with setting the column widths, we also need to conditionally render our text values too, or else text will be squeezed togeher with text from the neighboring columns. To achieve this we use ```<apex:outputText>``` wrapped in a ```<block>``` tag so we can use the ```rendered``` attribute. We tie our field reference or any text we want to display in the ```value``` attribute and then tie our controlling boolean ```showDiscount``` to the ```rendered``` attribute. This will effectively hide or show any text in the header and body for this column depending on the value of ```showDiscount```.
```
<table-header>
      <!-- Add bold text and shading -->
      <table-row font-weight="bold" background-color="#{!template.SBQQ__ShadingColor__c}">
          <!-- table-cells can have styling applied by specific attributes -->
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <!-- block tags act as divs and can be further styled -->
              <block>Product Code</block> 
          </table-cell>
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block>Product Name</block> 
          </table-cell>
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block>Quantity</block> 
          </table-cell>
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block>List Price</block> 
          </table-cell>
          <!-- Conditional column : Additional Discount Amount -->
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <!-- We use apex:outputText for its rendered attribute, we then need to wrap it in block tags -->
              <block><apex:outputText value="Additional Disc ($)" rendered="{!showDiscount}"/></block> 
          </table-cell>
          <!-- Conditional column : Additional Discount Discount -->
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block><apex:outputText value="Additional Disc (%)" rendered="{!showDiscount}"/></block>
          </table-cell>
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block>Net Price</block> 
          </table-cell>
          <table-cell padding="3px" border-style="solid" border-width="1px" text-align="center">
              <block>Net Total</block> 
          </table-cell>
      </table-row>
  </table-header>
```

### Dynamic Quote Header
(More to come soon!)

## Supported Visualforce tags
Visualforce pages used in Output Document Template Content are unique in that only specific tags and attributes are supported. If a tag or attribute is not supported then when generating a document, you will recieve the dreaded ```Error generating document: Bad Request``` error message. Most basic HTML and some Apex tags won't be supported as well as the style tag and any CSS.

Another limitation is the inability to have fonts of differing weights on the same line. For example, we wouldn't be able to have bold text and regular text on the same line. They would need to be separated within two block tags or potentially done in a hacky way using tables with invisible borders and meticulous text alignment.

During my experimenting I have a list of supported and unsupported tags that I've come across with many more to explore and test.

### Supported
1. block-container
2. block
   - font-weight
   - font-size
   - font-family
   - background-color
   - text-align
   - padding
   - margin-left
   - margin-right
3. table
   - width
4. table-column
   - column-width         
5. table-header
6. table-body
7. table-row
   - font-weight
   - background-color
8. table-cell
   - padding
   - border-style (applies to all sides)
   - border-top-style
   - border-bottom-style
   - border-right-style
   - border-left-style
   - border-width (applies to all sides)
   - border-top-width
   - border-bottom-width
   - border-right-width
   - border-left-width
   - text-align
9. apex:repeat
10. apex:outputText
11. apex:param
12. ```&nbsp;``` when wrapped in a block 


### Unsupported
1. Most common HTML tags
   - div
   - p
   - b (and any other font-weight tags)
   - h1 (and all other header tags)
   - a
   - span
2. style (including any CSS inline, internal or external)
3. br
4. apex:outputPanel

If you encounter any new tags or attributes that are supported/ not supported feel free to reach out to me at frank.berni@cognizant.com and I will update the lists accordingly.

## General Troubleshooting
Typically when generating a preview of a document the error message will either be clear or not depending on the error. 

The message is typically clear when displaying an Apex issue. Any common exceptions being thrown like a List out of bounds or a variable cannot be reached can be easily pinpointed within the code. We can also have the Developer Console open whenever we generate the document to see any logs that populate.

When the message states ```Error generating document: Bad Request``` is when it isn't so clear. This is when trial and error needs to be done to exactly pinpoint what is going wrong. When expanding upon the code, keep track of the list of supported and unsupported tags. If at one point the doc was generating fine but after a few changes it isn't, then rolling back changes one at a time and previewing again can help discover what parts aren't working. This type of tool is very restricting but with a little creative thinking, solutions are possible with the right tags and attributes!
