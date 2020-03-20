module.exports = {
    base: '/blog/',
    title: 'Java系统化知识体系',
    description: 'Vuepress blog demo',
    themeConfig: {
        repo: 'https://www.vuepress.cn/',
        repoLabel: 'VuePress',
        lastUpdated: '上次更新：',
        nav: [
            {text: '主页', link: '/'},
            {text: '技术体系', link: '/总纲'},
            {text: '面试题', link: '/面试题'},
            {text: '项目经历', link: '/项目经历'}
        ],
        sidebar: 'auto'
    },
    markdown: {
        //代码块显示行号
        lineNumbers: true
    }
};
