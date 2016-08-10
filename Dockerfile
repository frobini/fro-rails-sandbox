FROM phusion/passenger-ruby22:latest

ENV BUNDLE_WITHOUT test:development

EXPOSE 5000