global class UrlRewriter implements Site.UrlRewriter {
    
    global PageReference mapRequestUrl(PageReference yourFriendlyUrl) {
        
        String UI_PAGE = '/_ui/';
        string url = yourFriendlyUrl.getUrl().toLowerCase();
        
        if(url.contains(UI_PAGE)){	
            return new pagereference('/UrlRedirectPage');            
        }
        
        return yourFriendlyUrl;    
    }
    
    global List<PageReference> generateUrlFor(List<PageReference> yourSalesforceUrls) {
        System.debug('Entered generateUrlFor  :   '+yourSalesforceUrls);
        return null;
    }
}