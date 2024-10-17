// Get the url for the .jar file of the selected url documentation in javadoc.io
// Example of usage
// node javadocGetJarLink.js https://javadoc.io/doc/org.zaproxy/zap/latest/index.html
//
// Output
// https://javadoc.io/jar/org.zaproxy/zap/2.15.0/zap-2.15.0-javadoc.jar

const puppeteer = require('puppeteer-core');

// Get the target URL from command line arguments
const targetUrl = process.argv[2]; 


async function main () {
    const browser = await puppeteer.launch({
        executablePath: '/usr/bin/chromium'
    });
    const page = await browser.newPage();
    page.setDefaultTimeout(0);
    await page.goto(targetUrl);
    var urlPath = await page.$eval('a[data-original-title="download raw javadoc"]', (element) => {
        return element.getAttribute('href');
    });
    console.log(`https://javadoc.io${urlPath}`);

    await browser.close();
}

main();
