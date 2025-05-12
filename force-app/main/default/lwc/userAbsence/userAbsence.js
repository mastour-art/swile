import { LightningElement, wire, track } from 'lwc';
import getMyTeamMembers from '@salesforce/apex/TeamMemberController.getMyTeamMembers';
import updateUserPresence from '@salesforce/apex/TeamMemberController.updateUserPresence';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Nom', fieldName: 'Name', type: 'text' },
    { label: 'Compteur d\'assignations', fieldName: 'assignment_counter__c', type: 'number' },
    {
        label: 'Présent',
        type: 'text',
        cellAttributes: {
            iconName: { fieldName: 'presenceIcon' },
            alignment: 'right'
        }
    }
];

export default class UserAbsence extends LightningElement {
    wiredUsersResult;
    @track users;
    @track selectedUsers = [];
    columns = COLUMNS;

    @wire(getMyTeamMembers)
    wiredUsers(result) {
        this.wiredUsersResult = result; 
        if (result.data) {
            this.users = result.data.map(user => ({
                ...user,
                presenceIcon: user.is_absent__c ? 'utility:close' : 'utility:check',
            }));
        } else if (result.error) {
            console.error('Erreur lors de la récupération des utilisateurs:', result.error);
        }
    }

    handleRowSelection(event) {
        this.selectedUsers = event.detail.selectedRows;;
    }

    handleMarkAbsent() {
        this.updatePresence(true);
    }

    handleMarkPresent() {
        this.updatePresence(false);
    }

    updatePresence(isAbsent) {
        const userIds = this.selectedUsers.map(user => user.Id);
        updateUserPresence({ userIds, isAbsent })
            .then(() => refreshApex(this.wiredUsersResult))
            .then(() => this.showToast('Succès', 'Les présences ont été mises à jour', 'success'))
            .catch(err => this.showToast('Erreur', err.body?.message, 'error'));
    }

    showToast(title, message, variant = 'success') {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable',
        });
        this.dispatchEvent(evt);
    }
}
