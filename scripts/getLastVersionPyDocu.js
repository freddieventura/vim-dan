// Get the full url for downloading the last text docs.python

const puppeteer = require('puppeteer-core');

async function main () {
    const browser = await puppeteer.launch({
        executablePath: '/usr/bin/chromium'
    });
    const page = await browser.newPage();
    page.setDefaultTimeout(0);
    await page.goto('https://docs.python.org/3/download.html');


    var targetCol = await page.$eval('table', (element) => {
        return Array.from(element.querySelectorAll('th')).findIndex((el) => {
            return el.innerText === 'Packed as .tar.bz2';
        })
    });

    var targetRow = await page.$eval('table', (element) => {
        return Array.from(element.querySelectorAll('tr')).findIndex((el) => {
            return el.firstElementChild.innerText === 'Plain text';
        })
    });

    // CSS pseudo-class :nth-of-type works 1 indexed
    targetCol++;
    targetRow++;

    const urlPath = await page.$eval('table', (element, targetCol, targetRow) => {
        return element.querySelector(`tr:nth-of-type(${targetRow})`).querySelector(`td:nth-of-type(${targetCol})`).firstElementChild.getAttribute('href');
    }, targetCol, targetRow);

    console.log(`https://docs.python.org/3/${urlPath}`);

    await browser.close();
}

main();
