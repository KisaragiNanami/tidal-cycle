import rss from "@astrojs/rss";
import { getCollection } from "astro:content";

export const prerender = true;

export async function GET(context: any) {
  const posts = await getCollection("blog");
  const sortedPosts = posts.sort((a: any, b: any) => new Date(b.data.pubDate).getTime() - new Date(a.data.pubDate).getTime());
  return rss({
    title: "七海の心象素描",
    description: "ああかがやきの四月の底を、はぎしり燃えてゆききする。",
    site: context.site,
    items: sortedPosts.map((blog: any) => ({
      ...blog.data,
      link: `/blog/${blog.slug}/`,
    })),
  });
}
