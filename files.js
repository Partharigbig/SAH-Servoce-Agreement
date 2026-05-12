import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getFilesForLWC from '@salesforce/apex/MC_GetFilesList.getFilesForLWC';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import CONTENT_VERSION_OBJECT from '@salesforce/schema/ContentVersion';
import FILE_CATEGORY_FIELD from '@salesforce/schema/ContentVersion.File_Category__c';
import updateFileCategory from '@salesforce/apex/MC_GetFilesList.updateFileCategory';
import { NavigationMixin } from 'lightning/navigation';
import STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled, } from 'lightning/empApi';
const PAGE_SIZE = 10;
const COLUMNS = [
    /*{
        label: 'File Name',
        fieldName: 'previewButton',
        type: 'button',
        wrapText: true,
        cellAttributes: { 
                class: 'wrapText',
                alignment: 'left' 
            },
        typeAttributes: {
            label: { fieldName: 'Title' },
            variant: 'base', 
            name: 'preview',
            title: 'Preview File'
        },
        sortable: false
    },*/
    {
    label: 'File Name',
    fieldName: 'fileUrl',
    type: 'url',
    wrapText: true,
    cellAttributes: {
        alignment: 'left',
        class: 'wrapText'
    },
    typeAttributes: {
        label: { fieldName: 'Title' },
        target: '_self'
    },
    sortable: false
},

    { label: 'File Category', fieldName: 'File_Category__c', type: 'text', sortable: false },
    { label: 'Created Date', fieldName: 'formattedCreatedDate', type: 'text', sortable: false }
];

export default class MC_Files extends NavigationMixin(LightningElement) {
    @api recordId;
    @track files = [];
    @track columns = COLUMNS;
    wiredFilesResult;
    @track showModal = false;
    @track categoryOptions = [];
    @track selectedCategory = 'None';
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track selectedFileId = null;
    @track loadMoreStatus;
    @track totalRecords = 0;
    @track offset = 0;
    @track communityRecordId;
    @track isClosedOpportunity = false;
    subscription=null;
    channelName = '/event/MC_Refresh_Event__e';

    @wire(getObjectInfo, { objectApiName: CONTENT_VERSION_OBJECT })
    contentVersionInfo;

    @wire(getPicklistValues, { recordTypeId: '$contentVersionInfo.data.defaultRecordTypeId', fieldApiName: FILE_CATEGORY_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.categoryOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    connectedCallback() {
        if (window.location.hostname.includes('.my.site.com')) {
            this.extractRecordIdFromURL();
        }
        this.loadFiles();
        this.handleSubscribe();
    }
    handleSubscribe() {
        const self = this;
        const callbackFunction = function (response) {
            const eventRecordId = response?.data?.payload?.Record_Id__c;
            if (eventRecordId && eventRecordId == self.recordId) {
                self.refreshMethodCall();
            }
            
        }
        
        if (!this.subscription) {
            subscribe(this.channelName, -1, callbackFunction).then(response => {
                this.subscription = response;
            
                 
            });
        }
        
    }
    refreshMethodCall() {
        console.log('Refreshedddd');
        this.files = [];  
        this.offset = 0; 
        this.loadFiles();
    }
    disconnectedCallback() { 
        if (this.subscription) { 
            unsubscribe(this.subscription, response => { 
                //console.log('Unsubscribed from channel: ' + JSON.stringify(response)); 
                this.subscription = null; // clear reference 
            });
        }
    }
    loadFiles() {
        getFilesForLWC({ 
            parentRecordIds: [this.recordId], 
            pageSize: PAGE_SIZE, 
            offset: this.offset,
            sortBy: this.sortedBy,
            sortDirection: this.sortedDirection
        })
        .then(result => {
            this.processFiles(result); 
        })
        .catch(error => {
            console.error('Error fetching files:', error);
            this.files = [];
        });
    }


    /*processFiles(result) {
        if (result && result.files) {
            let newFiles = result.files.map(file => ({
                Id: file.Id,
                Title: file.Title,
                File_Category__c: file.ContentVersions?.[0]?.File_Category__c || 'N/A',
                CreatedDate: file.CreatedDate,
                formattedCreatedDate: this.formatDateTime(file.CreatedDate),
                //previewButton: file.Id 
                fileUrl: '/lightning/r/ContentDocument/' + file.Id + '/view'
            }));
            this.files = [...this.files, ...newFiles];
            this.totalRecords = result.totalRecords;
            this.offset += PAGE_SIZE;
            this.loadMoreStatus = this.offset < this.totalRecords ? 'Load More' : 'No More Data';
    }
    }*/
   
    processFiles(result) {
        console.log("ProcessFiles===============");
        console.log("Result===============",result);
        console.log("Result===============",result.files);
        if (result && result.files) {
            const newFiles = result.files.map(file => ({
                Id: file.Id,
                Title: file.Title,
                fileUrl: '/lightning/r/ContentDocument/' + file.Id + '/view',
                File_Category__c: file.ContentVersions?.[0]?.File_Category__c || 'N/A',
                CreatedDate: file.CreatedDate,
                formattedCreatedDate: this.formatDateTime(file.CreatedDate)
            }));
            this.files = [...this.files, ...newFiles];
            this.totalRecords = result.totalRecords;
            this.offset += PAGE_SIZE;
            this.loadMoreStatus = this.offset < this.totalRecords ? 'Load More' : 'No More Data';
        console.log("Files===============",JSON.stringify(this.files));
        }
    }

    @track formattedDate;
    formatDateTime(dateString) {
        if (!dateString) return '';
    
        const date = new Date(dateString);
        const options = { 
            day: '2-digit', 
            month: '2-digit', 
            year: 'numeric', 
            hour: '2-digit', 
            minute: '2-digit', 
            hour12: true 
        };
        
        this.formattedDate = new Intl.DateTimeFormat('en-GB', options).format(date);
    
        this.formattedDate = this.formattedDate.replace(/, /, ', ').replace(/(am|pm)/i, match => match.toUpperCase());

        return this.formattedDate;
        }
    
    /*@track action;
    handleRowAction(event) {
        this.action = event.detail.action;
        const row = event.detail.row;

        if (this.action.name === 'preview') {
            this.previewFile(row.Id); 
        }
    }

    previewFile(fileId) {
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: fileId,
                actionName: 'view'
            }
        });
    }*/

    handleLoadMore() {
        if (this.offset < this.totalRecords) {
            this.loadFiles();
        }
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.files = []; 
        this.offset = 0; 
        this.loadFiles(); 
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.target.value;
    }

    handleAddFilesClick() {
        this.showModal = true;
    }

    closeModal() {
        this.selectedCategory = 'None';
        this.showModal = false;
    }
    @track urlPath;
    extractRecordIdFromURL() {
        this.urlPath = window.location.pathname;
        

 
        const pathSegments = this.urlPath.split('/');

        const recordIndex = pathSegments.indexOf('Record');
        if (recordIndex !== -1 && pathSegments[recordIndex + 1]) {
            this.communityRecordId = pathSegments[recordIndex + 1];
        }

        console.log('Extracted recordId from Community:', this.communityRecordId);
    }

    get computedRecordId() {
        return this.communityRecordId || this.recordId; 
    }

    get disableFileUpload() {
        return !this.selectedCategory || this.selectedCategory === 'None'; 
    }

    get showCategoryWarning() {
        return !this.selectedCategory || this.selectedCategory === 'None'; 
    }
    @track stageName;
    @wire(getRecord, { recordId: '$recordId', fields: [STAGE_NAME_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.stageName = data.fields.StageName.value;
            this.isClosedOpportunity = this.stageName === 'Closed Won' || this.stageName === 'Closed Lost';
        } else if (error) {
            console.error('Error fetching Opportunity StageName:', error);
        }
    }
    
    get showAddFilesButton() {
        return !(this.isClosedOpportunity && this.recordId.startsWith('006'));
    }
    @track uploadfiles;
    handleUploadFinished(event) {
        this.uploadedFiles = event.detail.files;
    
        if (!this.selectedCategory) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a file category before uploading.',
                    variant: 'error'
                })
            );
            return;
        }
    
        const fileIds = this.uploadedFiles.map(file => file.documentId);
        updateFileCategory({ fileIds, category: this.selectedCategory })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File uploaded and category updated!',
                        variant: 'success'
                    })
                );
                this.selectedCategory = 'None';
                this.showModal = false; 
                this.files = [];
                this.offset = 0;
                this.loadFiles();
            })
            .catch(error => {
                console.error('Error updating file category:', error);
            });
    }
}
