trigger OpportunityTrigger on Opportunity( after insert, after update, before insert, before update) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);

    if( Trigger.isInsert ){
        if(Trigger.isBefore) {
            handler.OnBeforeInsert(trigger.New);
        }
        else {
            handler.OnAfterInsert(trigger.New);
        }
    }
    else if ( Trigger.isUpdate ) {
        if(Trigger.isBefore){
            handler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
        else{
            handler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }
}