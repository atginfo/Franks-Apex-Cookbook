public class GovernorLimitsHelper {

    public String context;
    
    public void printAllLimits(String context){

        //Ran into issue with this line due to static context, left all methods as instance ones
        this.context = context;

        printQueryLimits();
        printDMLLimits();
        printHeapSizeLimits();
        printCpuLimits();

    }

    public void printQueryLimits(){
        //System.debug('SOQL Query Limit in ' + context + ': ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }

    public void printDMLLimits(){
        //System.debug('DML Limit in ' + context + ': ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements());
    }

    public void printHeapSizeLimits(){
        //System.debug('Heap Size Limit in ' + context + ': ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
    }

    public void printCpuLimits(){
        //System.debug('Apex CPU Limit in ' + context + ': ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
    }

}