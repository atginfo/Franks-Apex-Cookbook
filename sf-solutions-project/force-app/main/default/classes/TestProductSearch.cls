global class TestProductSearch implements SBQQ.ProductSearchPlugin{
    
    //Constructor not required
    global TestProductSearch(){
        System.debug('Constructor Entered for Test Product Search');
	}
    
    //Required methods for this interface
    global Boolean isFilterHidden(SObject quote, String fieldName){
        System.debug('METHOD CALLED: isFilterHidden');
		/*
		// This would hide Product Code filter if Quote Status is Approved
		return fieldName == 'ProductCode' && quote.SBQQ__Status__c == 'Approved';
		*/
		return false;
	}
    
    global String getFilterDefaultValue(SObject quote, String fieldName){
		System.debug('METHOD CALLED: getFilterDefaultValue');
		/*
		// This would set Product Family filter to Service if Quote Type is Quote
		return (fieldName == 'Family' && quote.SBQQ__Type__c == 'Quote') ? 'Service' : NULL;
		*/
		return NULL;
	}
    
    global Boolean isSearchCustom(SObject quote, Map<String,Object> fieldValuesMap){
		/*
		// This would use CUSTOM mode if a Search field for sorting was defined and used
		return fieldValuesMap.get('Sort_By__c') != '';
		*/
		return false;
	}
    
    global Boolean isInputHidden(SObject quote, String input){
		System.debug('METHOD CALLED: isInputHidden');
		/*
		// This would hide an Input called 'Urgent Shipment' on Fridays.
		return input == 'Urgent Shipment' && Datetime.now().format('F') == 5;
		*/
		return false;
	}
    
    global String getInputDefaultValue(SObject quote, String input){
		System.debug('METHOD CALLED: getInputDefaultValue');
		//Get Default value for input if available.
		return NULL;
	}

	global Boolean isSuggestCustom(SObject quote, Map<String,Object> inputValuesMap){
        System.debug('METHOD CALLED: isSuggestCustom');
        // Original code had one parentheis which caused an error, adding missing one to see if it runs
        return inputValuesMap.get('Purpose__c') == null;
	}
    
    global String getAdditionalSearchFilters(SObject quote, Map<String,Object> fieldValuesMap){
		System.debug('METHOD CALLED: getAdditionalSearchFilters');
		//Won't use for guided selling.
		return NULL;
	}
    
    global String getAdditionalSuggestFilters(SObject quote, Map<String,Object> fieldValuesMap){
		Set<Id> setBundleId = new Set<Id>();
        String additionalFilter = NULL;
        
        //Suggest to use custom metadata here to dictate behavior so that it is more easily maintainble.
        
        //Query for existing Quote Lines where Bundle and get ProductId
        for(SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c 
                                     WHERE SBQQ__RequiredBy__c = null AND SBQQ__Quote__c = :quote.Id]){
            setBundleId.add(ql.SBQQ__Product__c);
        }
        
        if(setBundleId.size()>0){
            //Turn to string for dynamic soql
        	String bundleFilter = inClausify(setBundleId);
            additionalFilter = 'Product2.Id NOT IN '+ bundleFilter;
        }
        
		return additionalFilter;
	}

    global List<PriceBookEntry> search(SObject quote, Map<String,Object> fieldValuesMap){
		System.debug('METHOD CALLED: search');
		//Won't use for guided selling.
		List<PriceBookEntry> pbes = new List<PriceBookEntry>();
		return pbes;
	}
    
    global List<PriceBookEntry> suggest(SObject quote, Map<String,Object> fieldValuesMap){
		System.debug('METHOD CALLED: suggest');
        
		//GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
		List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();
		//GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
		List<Schema.FieldSetMember> searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();

		//BUILD THE SELECT STRING
		String selectClause = 'SELECT ';

		for(Schema.FieldSetMember field : searchResultFieldSetFields){
			selectClause += 'Product2.' + field.getFieldPath() + ', ';
		}
        selectClause += 'Id, UnitPrice, PriceBook2Id, Product2Id, Product2.Id';
        
        System.debug('select clause: '+selectClause);

        //BUILD THE WHERE CLAUSE
        String whereClause = '';

		for(Schema.FieldSetMember field : searchFilterFieldSetFields){
			if(!fieldValuesMap.containsKey(field.getFieldPath())){
				continue;
			}

			if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
				whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(field.getFieldPath()) + '%\' AND ';
			}
		}

            //Add Hardware Filter for demo purposes
            whereClause += 'Product2.Family = \'Hardware\' AND ';

		whereClause += 'PriceBook2Id = \'' + quote.get('SBQQ__PriceBookId__c') + '\'';

		//BUILD THE QUERY
		String query = selectClause + ' FROM PriceBookEntry WHERE ' + whereClause;

		//DO THE QUERY
		List<PriceBookEntry> pbes = new List<PriceBookEntry>();
		pbes = Database.query(query);

		return pbes;
	}

    private String inClausify(Set<Id> ids) {
        String inClause = String.format( '(\'\'{0}\'\')', 
                             new List<String> { String.join( new List<Id>(ids) , '\',\'') });
        return inClause;
    }

}